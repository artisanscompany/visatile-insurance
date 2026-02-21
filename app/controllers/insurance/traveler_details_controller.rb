# frozen_string_literal: true

module Insurance
  class TravelerDetailsController < InsuranceController
    before_action :require_quote_data

    def new
      traveler_count = insurance_session.dig("quote_request", "traveler_birth_dates")&.size || 1

      render inertia: "Insurance/TravelerDetail/New", props: {
        traveler_count: traveler_count,
        traveler_birth_dates: insurance_session.dig("quote_request", "traveler_birth_dates") || [],
        saved_travelers: insurance_session["travelers"]
      }
    end

    def create
      insurance_session["travelers"] = travelers_params
      redirect_to new_insurance_checkout_path
    end

    private

    def travelers_params
      params.require(:travelers).map do |t|
        t.permit(:first_name, :last_name, :birth_date, :passport_number, :passport_country).to_h
      end
    end
  end
end
