# frozen_string_literal: true

module Api
  module Sessions
    class MagicLinksController < Api::BaseController
      rate_limit to: 10, within: 15.minutes, only: :create,
        with: -> { render json: { error: "Too many attempts. Wait 15 minutes." }, status: :too_many_requests }

      def create
        code = params.require(:code)

        if (magic_link = MagicLink.consume(code))
          if email_address_pending_authentication_matches?(magic_link.identity.email_address)
            start_new_session_for(magic_link.identity)
            clear_pending_email

            redirect_url = after_sign_in_url(magic_link)

            render json: {
              status: "authenticated",
              redirect_to: redirect_url,
              user: {
                email: magic_link.identity.email_address
              }
            }
          else
            render json: { error: "Authentication failed. Please try again." }, status: :unprocessable_entity
          end
        else
          render json: { error: "Invalid or expired code. Please try again." }, status: :unprocessable_entity
        end
      end

      private

      def after_sign_in_url(magic_link)
        if magic_link.for_sign_up?
          registration_completion_path
        elsif session[:pending_invite_token].present?
          invite_path(session[:pending_invite_token])
        else
          after_authentication_url
        end
      end
    end
  end
end
