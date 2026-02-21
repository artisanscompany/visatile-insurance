# frozen_string_literal: true

module Stripe
  class WebhooksController < ApplicationController
    skip_before_action :verify_authenticity_token
    allow_unauthenticated_access
    disallow_account_scope

    def create
      payload = request.body.read
      sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
      event = ::Stripe::Webhook.construct_event(
        payload, sig_header, ENV.fetch("STRIPE_WEBHOOK_SECRET")
      )

      case event.type
      when "checkout.session.completed"
        handle_checkout_completed(event.data.object)
      end

      head :ok
    rescue ::Stripe::SignatureVerificationError
      head :bad_request
    rescue => e
      Rails.logger.error("Stripe webhook error: #{e.message}")
      head :ok
    end

    private

    def handle_checkout_completed(session)
      policy_id = session.metadata["policy_id"]
      return unless policy_id

      policy = InsurancePolicy.find(policy_id)

      # Idempotency: skip if already processed for this checkout session
      return if PolicyPaymentReceived.exists?(policy_id: policy_id, stripe_checkout_session_id: session.id)

      PolicyPaymentReceived.create!(
        policy_id: policy_id,
        stripe_payment_intent_id: session.payment_intent,
        stripe_checkout_session_id: session.id,
        amount_received: session.amount_total / 100.0,
        currency: session.currency.upcase
      )

      policy.fulfill_later
    end
  end
end
