class Session < ApplicationRecord
  EXPIRATION_PERIOD = 30.days

  belongs_to :identity

  scope :active, -> { where("expires_at > ?", Time.current) }
  scope :expired, -> { where("expires_at <= ?", Time.current) }

  before_create :set_expiration

  def expired?
    expires_at <= Time.current
  end

  def refresh!
    update!(expires_at: EXPIRATION_PERIOD.from_now)
  end

  private

  def set_expiration
    self.expires_at ||= EXPIRATION_PERIOD.from_now
  end
end
