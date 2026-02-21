class PolicyFailed < ApplicationRecord
  include PolicyState

  belongs_to :creator, class_name: "Identity", foreign_key: :created_by_id, optional: true
end
