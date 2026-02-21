# frozen_string_literal: true

module Insurance
  class QuoteReviewsController < InsuranceController
    before_action :require_quote_data

    def show
      render inertia: "Insurance/QuoteReview/Show", props: {
        quote_request: insurance_session["quote_request"],
        quote_response: insurance_session["quote_response"]
      }
    end
  end
end
