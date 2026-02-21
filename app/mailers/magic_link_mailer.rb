# frozen_string_literal: true

class MagicLinkMailer < ApplicationMailer
  def sign_in_instructions(magic_link)
    @magic_link = magic_link
    @identity = magic_link.identity
    @code = magic_link.code

    mail(
      to: @identity.email_address,
      subject: "Your sign-in code is #{@code}"
    )
  end
end
