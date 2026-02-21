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

      InsurancePolicy.find(policy_id).record_payment!(session)
    end
  end
end
