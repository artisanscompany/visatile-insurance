class Account < ApplicationRecord
  delegated_type :accountable, types: %w[IndividualAccount TeamAccount], dependent: :destroy

  has_many :users, dependent: :destroy
  has_many :identities, through: :users
  has_many :invites, dependent: :destroy
  has_many :insurance_policies, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  normalizes :slug, with: ->(value) { value.to_s.encode("UTF-8").parameterize.presence }

  before_validation :generate_slug, on: :create

  def self.create_individual_for(identity:, user_name:, account_name:)
    transaction do
      individual_account = IndividualAccount.create!
      account = create!(
        name: account_name,
        accountable: individual_account
      )
      account.users.create!(
        identity: identity,
        name: user_name,
        role: :owner
      )
      account
    end
  end

  def self.create_team(name:, owner_identity:, owner_name:)
    transaction do
      team_account = TeamAccount.create!
      account = create!(
        name: name,
        accountable: team_account
      )
      account.users.create!(
        identity: owner_identity,
        name: owner_name,
        role: :owner
      )
      account
    end
  end

  def individual?
    accountable_type == "IndividualAccount"
  end

  def team?
    accountable_type == "TeamAccount"
  end

  private

  def generate_slug
    return if slug.present?

    base_slug = name.parameterize
    candidate = base_slug

    counter = 1
    while Account.exists?(slug: candidate)
      counter += 1
      candidate = "#{base_slug}-#{counter}"
    end

    self.slug = candidate
  end

  # Override save to handle slug conflicts at database level (prevents race conditions)
  def save(**options, &block)
    super
  rescue ActiveRecord::RecordNotUnique => e
    raise unless e.message.include?("slug")

    @slug_conflict_counter ||= 1
    @slug_conflict_counter += 1
    self.slug = "#{name.parameterize}-#{@slug_conflict_counter}"
    retry if @slug_conflict_counter < 100
    raise
  end
end
