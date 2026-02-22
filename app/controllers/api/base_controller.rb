# frozen_string_literal: true

module Api
  class BaseController < ApplicationController
    include Authentication

    disallow_account_scope
    allow_unauthenticated_access

    protect_from_forgery with: :exception

    rescue_from ActionController::ParameterMissing do |e|
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end
end
