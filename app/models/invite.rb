# frozen_string_literal: true

class Invite < ApplicationRecord
  EXPIRATION_PERIOD = 7.days

  belongs_to :account
  belongs_to :inviter, class_name: "User"

  enum :role, { member: "member", admin: "admin" }, default: :member

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true

  normalizes :email, with: ->(value) { value.strip.downcase }

  before_validation :generate_token, on: :create
  before_validation :set_expiration, on: :create

  scope :pending, -> { where(accepted_at: nil).where("expires_at > ?", Time.current) }
  scope :expired, -> { where(accepted_at: nil).where("expires_at <= ?", Time.current) }
  scope :accepted, -> { where.not(accepted_at: nil) }

  def pending?
    accepted_at.nil? && expires_at > Time.current
  end

  def expired?
    accepted_at.nil? && expires_at <= Time.current
  end

  def accepted?
    accepted_at.present?
  end

  def accept!(identity:, user_name:)
    return false unless pending?

    transaction do
      update!(accepted_at: Time.current)
      account.users.create!(
        identity: identity,
        name: user_name,
        role: role
      )
    end
  end

  private

  def generate_token
    self.token ||= SecureRandom.urlsafe_base64(32)
  end

  def set_expiration
    self.expires_at ||= EXPIRATION_PERIOD.from_now
  end
end
