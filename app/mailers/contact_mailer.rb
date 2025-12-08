class ContactMailer < ApplicationMailer
  def contact_email(contact)
    @contact = contact
    mail(
      to: "hello@cr4fts.com",
      subject: "New Contact Form Submission from #{contact.name}",
      reply_to: contact.email
    )
  end
end
