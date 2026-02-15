class ContactsController < ApplicationController
  def create
    @contact = Contact.new(contact_params)

    if @contact.valid?
      ContactMailer.contact_email(
        name: @contact.name,
        email: @contact.email,
        message: @contact.message
      ).deliver_later

      ContactMailer.confirmation_email(
        name: @contact.name,
        email: @contact.email
      ).deliver_later

      redirect_to root_path(anchor: "contact"), notice: "Thanks for reaching out! We'll get back to you soon."
    else
      redirect_back fallback_location: root_path(anchor: "contact"),
        inertia: { errors: @contact.errors.to_hash(true) }
    end
  end

  private

  def contact_params
    params.require(:contact).permit(:name, :email, :message)
  end
end
