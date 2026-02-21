# frozen_string_literal: true

class SessionsController < InertiaController
  disallow_account_scope
  require_unauthenticated_access except: :destroy
  rate_limit to: 10, within: 3.minutes, only: :create,
    with: -> { redirect_to new_session_path, alert: "Try again later." }

  def new
    render inertia: "Sessions/New", props: {}
  end

  def create
    if (identity = Identity.find_by(email_address: email_address))
      magic_link = identity.send_magic_link
      store_pending_email(email_address)
      serve_development_magic_link(magic_link)
      redirect_to session_magic_link_path, notice: "Check your email for a sign-in code."
    else
      store_pending_email(email_address)
      redirect_to new_registration_path
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, notice: "You've been signed out."
  end

  private

  def email_address
    params.expect(:email_address)
  end
end
