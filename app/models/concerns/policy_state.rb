module PolicyState
  extend ActiveSupport::Concern

  included do
    belongs_to :insurance_policy, foreign_key: :policy_id

    scope :latest, -> { order(created_at: :desc) }
    scope :latest_first, -> { latest.limit(1) }

    after_create :touch_policy
  end

  private

  def touch_policy
    insurance_policy.touch
  end
end
