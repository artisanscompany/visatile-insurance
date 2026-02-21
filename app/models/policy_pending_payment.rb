class PolicyPendingPayment < ApplicationRecord
  include PolicyState

  validates :stripe_checkout_session_id, presence: true
end
