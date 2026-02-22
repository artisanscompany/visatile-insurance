# frozen_string_literal: true

module Api
  module Insurance
    class CheckoutsController < Api::BaseController
      def create
        policy, stripe_session = InsurancePolicy.purchase!(
          email: params.require(:email).strip.downcase,
          quote_request: checkout_params[:quote_request].to_h,
          quote_response: checkout_params[:quote_response].to_h,
          travelers_data: checkout_params[:travelers].map(&:to_h),
          request_base_url: request.base_url,
          panel_mode: true
        )

        render json: { stripe_url: stripe_session.url, policy_id: policy.id }
      rescue => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      private

      def checkout_params
        params.permit(
          :email,
          quote_request: {},
          quote_response: {},
          travelers: [:first_name, :last_name, :birth_date, :passport_number, :passport_country]
        )
      end
    end
  end
end
