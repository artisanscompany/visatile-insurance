class ContactMailer < ApplicationMailer
  def contact_email(name:, email:, message:)
    @name = name
    @email = email
    @message = message

    mail(
      to: "hello@cr4fts.com",
      subject: "New Contact Form Submission from #{name}",
      reply_to: email
    )
  end
end
