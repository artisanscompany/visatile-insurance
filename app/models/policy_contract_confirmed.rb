class PolicyContractConfirmed < ApplicationRecord
  include PolicyState

  validates :insurs_order_id, presence: true
end
