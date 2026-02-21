# frozen_string_literal: true

module Sessions
  class MagicLinksController < InertiaController
    disallow_account_scope
    require_unauthenticated_access
    rate_limit to: 10, within: 15.minutes, only: :create,
      with: -> { redirect_to session_magic_link_path, alert: "Wait 15 minutes, then try again" }

    def show
      render inertia: "Sessions/Verify", props: {
        email: pending_authentication_email
      }
    end

    def create
      if (magic_link = MagicLink.consume(code))
        authenticate_with(magic_link)
      else
        redirect_to session_magic_link_path, flash: {
          alert: "Invalid or expired code. Please try again.",
          shake: Time.current.to_f  # Unique timestamp to trigger input clearing
        }
      end
    end

    private

    def authenticate_with(magic_link)
      if email_address_pending_authentication_matches?(magic_link.identity.email_address)
        start_new_session_for(magic_link.identity)
        clear_pending_email
        redirect_to after_sign_in_url(magic_link)
      else
        redirect_to new_session_path, alert: "Authentication failed. Please try again."
      end
    end

    def after_sign_in_url(magic_link)
      if magic_link.for_sign_up?
        registration_completion_path
      elsif session[:pending_invite_token].present?
        invite_path(session[:pending_invite_token])
      else
        after_authentication_url
      end
    end

    def code
      params.expect(:code)
    end
  end
end
