# frozen_string_literal: true

class RegistrationsController < InertiaController
  disallow_account_scope
  require_unauthenticated_access except: %i[complete finish]
  allow_unauthenticated_access only: %i[complete finish]
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

  def complete
    redirect_to new_session_path unless authenticated?
    render inertia: "Registrations/Complete", props: {
      identity: {
        email_address: Current.identity&.email_address
      }
    }
  end

  def finish
    redirect_to new_session_path unless authenticated?

    account = Account.create_individual_for(
      identity: Current.identity,
      user_name: name_param,
      account_name: account_name_param
    )

    Current.account = account
    Current.user = account.users.find_by(identity: Current.identity)

    redirect_to root_path, notice: "Welcome! Your workspace has been created."
  end

  private

  def email_address
    params.expect(:email_address)
  end

  def name_param
    params.expect(:name)
  end

  def account_name_param
    params.expect(:account_name)
  end
end
