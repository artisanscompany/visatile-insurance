# frozen_string_literal: true

module Insurance
  class CheckoutsController < InsuranceController
    before_action :require_quote_data
    before_action :require_traveler_data

    def new
      render inertia: "Insurance/Checkout/New", props: {
        quote_request: insurance_session["quote_request"],
        quote_response: insurance_session["quote_response"],
        travelers: insurance_session["travelers"]
      }
    end

    def create
      _policy, stripe_session = InsurancePolicy.purchase!(
        email: params.require(:email).strip.downcase,
        quote_request: insurance_session["quote_request"],
        quote_response: insurance_session["quote_response"],
        travelers_data: insurance_session["travelers"],
        request_base_url: request.base_url
      )

      session.delete(:insurance_flow)
      inertia_location(stripe_session.url)
    end
  end
end
