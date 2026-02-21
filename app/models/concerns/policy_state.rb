module PolicyState
  extend ActiveSupport::Concern

  included do
    belongs_to :insurance_policy, foreign_key: :policy_id
  end
end
