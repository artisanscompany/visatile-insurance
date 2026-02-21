class PolicyMailer < ApplicationMailer
  def confirmation(policy)
    @policy = policy
    @identity = policy.account.identities.first

    mail(
      to: @identity.email_address,
      subject: "Your travel insurance policy is confirmed"
    )
  end
end
