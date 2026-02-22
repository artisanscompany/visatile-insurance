# frozen_string_literal: true

module Api
  class SessionsController < Api::BaseController
    rate_limit to: 10, within: 3.minutes, only: :create,
      with: -> { render json: { error: "Too many requests. Try again later." }, status: :too_many_requests }

    def create
      email = params.require(:email_address).strip.downcase

      if (identity = Identity.find_by(email_address: email))
        magic_link = identity.send_magic_link
        store_pending_email(email)

        response_data = { status: "sent", email: email }
        response_data[:magic_link_code] = magic_link&.code if Rails.env.development?

        render json: response_data
      else
        store_pending_email(email)
        render json: { status: "not_found", email: email, redirect_to: "/registration/new" }
      end
    end
  end
end
