class MagicLink < ApplicationRecord
  CODE_LENGTH = 6
  EXPIRATION_TIME = 15.minutes

  belongs_to :identity

  enum :purpose, { sign_in: "sign_in", sign_up: "sign_up" }, prefix: :for, default: :sign_in

  scope :active, -> { where(expires_at: Time.current..) }
  scope :stale, -> { where(expires_at: ..Time.current) }

  before_validation :generate_code, on: :create
  before_validation :set_expiration, on: :create

  validates :code, uniqueness: true, presence: true

  class << self
    def consume(code)
      sanitized = sanitize_code(code)
      return nil unless sanitized.present? && sanitized.length == CODE_LENGTH

      # Use constant-time comparison to prevent timing attacks
      active.find_each do |magic_link|
        if ActiveSupport::SecurityUtils.secure_compare(magic_link.code, sanitized)
          return magic_link.consume
        end
      end
      nil
    end

    def cleanup
      stale.delete_all
    end

    def sanitize_code(code)
      code.to_s.gsub(/\D/, "").first(CODE_LENGTH)
    end
  end

  def consume
    destroy
    self
  end

  def expired?
    expires_at < Time.current
  end

  private

  def generate_code
    self.code ||= loop do
      candidate = SecureRandom.random_number(10**CODE_LENGTH).to_s.rjust(CODE_LENGTH, "0")
      break candidate unless self.class.exists?(code: candidate)
    end
  end

  def set_expiration
    self.expires_at ||= EXPIRATION_TIME.from_now
  end
end
