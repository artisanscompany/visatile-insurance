class PolicyRefundInitiated < ApplicationRecord
  include PolicyState

  belongs_to :initiator, class_name: "Identity", foreign_key: :initiated_by_id

  validates :stripe_payment_intent_id, :reason, presence: true
end
