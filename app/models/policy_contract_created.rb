class PolicyContractCreated < ApplicationRecord
  include PolicyState

  validates :insurs_order_id, :insurs_police_num, :total_amount, presence: true
end
