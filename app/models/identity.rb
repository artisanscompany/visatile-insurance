class Identity < ApplicationRecord
  has_many :magic_links, dependent: :destroy
  has_many :sessions, dependent: :destroy
  has_many :users, dependent: :nullify
  has_many :accounts, through: :users

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  normalizes :email_address, with: ->(value) { value.strip.downcase.presence }

  def superuser?
    superuser
  end

  def send_magic_link(**attributes)
    magic_links.create!(attributes).tap do |magic_link|
      MagicLinkMailer.sign_in_instructions(magic_link).deliver_later
    end
  end
end
