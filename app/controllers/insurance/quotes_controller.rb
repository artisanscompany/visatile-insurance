# frozen_string_literal: true

module Insurance
  class QuotesController < InsuranceController
    def new
      render inertia: "Insurance/Quote/New", props: {
        coverage_tiers: InsurancePolicy::COVERAGE_LABELS
      }
    end

    def create
      client = InsursClient.new
      result = client.get_price(**quote_params.to_h.symbolize_keys)
      tariff = result["tariff"].first

      insurance_session["quote_request"] = quote_params.to_h
      insurance_session["quote_response"] = {
        "tariff_id" => tariff["tariff_id"],
        "tariff_name" => tariff["tariff_name"],
        "price_amount" => tariff["price"].to_s,
        "price_currency" => tariff["currency"] || "USD",
        "coverage_tier" => quote_params[:coverage_tier].to_i,
        "start_date" => quote_params[:start_date],
        "end_date" => quote_params[:end_date],
        "traveler_count" => quote_params[:traveler_birth_dates].size,
        "locality_coverage" => 237
      }

      redirect_to insurance_quote_review_path
    rescue InsursClient::ApiError => e
      redirect_to new_insurance_quote_path, alert: "Could not get a quote: #{e.message}"
    end

    private

    def quote_params
      params.require(:quote).permit(
        :start_date, :end_date, :departure_country, :coverage_tier,
        destination_countries: [], traveler_birth_dates: []
      )
    end
  end
end
