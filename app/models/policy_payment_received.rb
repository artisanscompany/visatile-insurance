class PolicyPaymentReceived < ApplicationRecord
  include PolicyState

  validates :stripe_payment_intent_id, :stripe_checkout_session_id, :currency, presence: true
  validates :amount_received, presence: true, numericality: { greater_than: 0 }
end
