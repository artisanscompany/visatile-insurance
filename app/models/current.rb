class Current < ActiveSupport::CurrentAttributes
  attribute :session, :user, :identity, :account
  attribute :request_id, :user_agent, :ip_address

  def session=(session)
    super
    self.identity = session&.identity
  end

  def identity=(identity)
    super
    self.user = identity&.users&.find_by(account: account) if identity.present? && account.present?
  end

  def user=(user)
    super
    self.identity ||= user&.identity
    self.account ||= user&.account
  end
end
