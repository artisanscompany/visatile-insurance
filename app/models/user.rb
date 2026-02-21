class User < ApplicationRecord
  belongs_to :identity
  belongs_to :account

  has_many :sent_invites, class_name: "Invite", foreign_key: :inviter_id, dependent: :nullify

  enum :role, { member: "member", admin: "admin", owner: "owner" }, default: :member

  validates :name, presence: true
  validates :identity_id, uniqueness: { scope: :account_id }

  scope :alphabetically, -> { order(name: :asc) }

  def owner?
    role == "owner"
  end

  def admin?
    role == "admin"
  end

  def member?
    role == "member"
  end

  def can_manage_members?
    admin? || owner?
  end

  def can_change_roles?
    owner?
  end

  def can_remove_member?(other_user)
    return false if other_user == self
    return false if other_user.owner? && !owner?

    can_manage_members?
  end
end
