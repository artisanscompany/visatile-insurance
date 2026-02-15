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

      create_crewsbase_row(@contact)

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

  def create_crewsbase_row(contact)
    uri = URI("https://crewsbase.app/api/crm/rows")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = "Bearer #{ENV["CREWSBASE_API_KEY"]}"
    request["Content-Type"] = "application/json"
    request.body = {
      values: {
        "5ed136b8-9189-4186-b935-b9d1057cc72a" => contact.name,
        "9c419222-8a80-4c38-8ef7-2d53bcb5aab9" => contact.email,
        "e7d4b9fc-383b-44fb-814a-41dcc5dcb8ea" => contact.message
      }
    }.to_json

    http.request(request)
  rescue => e
    Rails.logger.error("Crewsbase API error: #{e.message}")
  end
end
