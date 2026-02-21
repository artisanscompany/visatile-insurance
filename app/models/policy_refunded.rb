class PolicyRefunded < ApplicationRecord
  include PolicyState

  validates :stripe_refund_id, presence: true
  validates :amount_refunded, presence: true, numericality: { greater_than: 0 }
end
