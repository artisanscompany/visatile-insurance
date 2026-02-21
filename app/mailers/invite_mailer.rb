# frozen_string_literal: true

class InviteMailer < ApplicationMailer
  def invitation(invite)
    @invite = invite
    @account = invite.account
    @inviter = invite.inviter
    @accept_url = invite_url(invite.token)

    mail(
      to: invite.email,
      subject: "You've been invited to join #{@account.name}"
    )
  end
end
