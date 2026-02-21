# frozen_string_literal: true

class RegistrationsController < InertiaController
  disallow_account_scope
  require_unauthenticated_access
  rate_limit to: 10, within: 3.minutes, only: :create,
    with: -> { redirect_to new_registration_path, alert: "Try again later." }

  def new
    render inertia: "Registrations/New", props: {
      email: pending_authentication_email
    }
  end

  def create
    identity = Identity.find_or_create_by!(email_address: email_address)
    magic_link = identity.send_magic_link(purpose: :sign_up)
    store_pending_email(email_address)
    serve_development_magic_link(magic_link)
    redirect_to session_magic_link_path, notice: "Check your email for a verification code."
  end

  private

  def email_address
    params.expect(:email_address)
  end
end
