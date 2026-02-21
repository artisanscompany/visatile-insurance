class InsurancePolicy < ApplicationRecord
  include PolicyStateable
  include PolicyFulfillable

  belongs_to :account

  has_many :travelers, dependent: :destroy

  has_many :pending_payments, class_name: "PolicyPendingPayment", foreign_key: :policy_id, dependent: :destroy
  has_many :payment_receiveds, class_name: "PolicyPaymentReceived", foreign_key: :policy_id, dependent: :destroy
  has_many :contract_createds, class_name: "PolicyContractCreated", foreign_key: :policy_id, dependent: :destroy
  has_many :contract_confirmeds, class_name: "PolicyContractConfirmed", foreign_key: :policy_id, dependent: :destroy
  has_many :completeds, class_name: "PolicyCompleted", foreign_key: :policy_id, dependent: :destroy
  has_many :faileds, class_name: "PolicyFailed", foreign_key: :policy_id, dependent: :destroy
  has_many :refund_initiateds, class_name: "PolicyRefundInitiated", foreign_key: :policy_id, dependent: :destroy
  has_many :refundeds, class_name: "PolicyRefunded", foreign_key: :policy_id, dependent: :destroy

  COVERAGE_AMOUNTS = { 1 => 35_000, 2 => 100_000, 3 => 500_000 }.freeze
  COVERAGE_LABELS = { 1 => "Standard", 2 => "Advanced", 3 => "Premium" }.freeze

  scope :recently_created, -> { order(created_at: :desc) }

  def self.purchase!(email:, quote_request:, quote_response:, travelers_data:, request_base_url:)
    identity = Identity.find_or_create_by!(email_address: email)
    account = identity.accounts.first || Account.create_individual_for(
      identity: identity,
      user_name: email.split("@").first,
      account_name: "Personal"
    )

    policy = account.insurance_policies.create!(
      start_date: quote_request["start_date"],
      end_date: quote_request["end_date"],
      departure_country: quote_request["departure_country"],
      destination_countries: quote_request["destination_countries"],
      locality_coverage: quote_response["locality_coverage"] || 237,
      coverage_tier: quote_request["coverage_tier"].to_i,
      price_amount: quote_response["price_amount"],
      price_currency: quote_response["price_currency"] || "USD"
    )

    travelers_data.each { |t| policy.travelers.create!(t.symbolize_keys) }

    stripe_session = ::Stripe::Checkout::Session.create(
      payment_method_types: [ "card" ],
      mode: "payment",
      customer_email: email,
      line_items: [ {
        price_data: {
          currency: policy.price_currency.downcase,
          product_data: { name: "Travel Insurance - #{policy.coverage_label}" },
          unit_amount: (policy.price_amount * 100).to_i
        },
        quantity: 1
      } ],
      metadata: { policy_id: policy.id },
      success_url: "#{request_base_url}/insurance/confirmation?session_id={CHECKOUT_SESSION_ID}&policy_id=#{policy.id}",
      cancel_url: "#{request_base_url}/insurance/checkout/new"
    )

    policy.pending_payments.create!(stripe_checkout_session_id: stripe_session.id)

    [ policy, stripe_session ]
  end

  def record_payment!(stripe_session)
    return if PolicyPaymentReceived.exists?(policy_id: id, stripe_checkout_session_id: stripe_session.id)

    payment_receiveds.create!(
      stripe_payment_intent_id: stripe_session.payment_intent,
      stripe_checkout_session_id: stripe_session.id,
      amount_received: stripe_session.amount_total / 100.0,
      currency: stripe_session.currency.upcase
    )

    fulfill_later
  end

  def initiate_refund!(reason:, identity:)
    payment = payment_receiveds.order(created_at: :desc).first!

    refund_initiateds.create!(
      stripe_payment_intent_id: payment.stripe_payment_intent_id,
      reason: reason,
      initiated_by_id: identity.id
    )
  end

  def coverage_amount
    COVERAGE_AMOUNTS[coverage_tier]
  end

  def coverage_label
    COVERAGE_LABELS[coverage_tier]
  end
end
