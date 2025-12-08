class ContactsController < ApplicationController
  def create
    @contact = Contact.new(contact_params)

    if @contact.valid?
      # Send notification email to CR4FTS
      ContactMailer.contact_email(
        name: @contact.name,
        email: @contact.email,
        message: @contact.message
      ).deliver_later

      # Send confirmation email to user
      ContactMailer.confirmation_email(
        name: @contact.name,
        email: @contact.email
      ).deliver_later

      respond_to do |format|
        format.html { redirect_to root_path(anchor: "contact"), notice: "Thanks for reaching out! We'll get back to you soon." }
        format.turbo_stream { head :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to root_path(anchor: "contact"), alert: "Please fix the errors in the form." }
        format.turbo_stream { head :unprocessable_entity }
      end
    end
  end

  private

  def contact_params
    params.require(:contact).permit(:name, :email, :message)
  end
end
