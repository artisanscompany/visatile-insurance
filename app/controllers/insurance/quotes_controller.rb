# frozen_string_literal: true

module Insurance
  class QuotesController < InsuranceController
    def new
      render inertia: "Insurance/Quote/New", props: {
        coverage_tiers: InsurancePolicy::COVERAGE_LABELS,
        prefill: {
          start_date: params[:start_date] || "",
          end_date: params[:end_date] || "",
          destination: params[:destination] || ""
        }
      }
    end

    def create
      client = InsursClient.new
      normalized = normalize_quote_params
      result = client.get_price(**normalized.symbolize_keys)
      tariff = result["data"].first

      insurance_session["quote_request"] = normalized
      insurance_session["quote_response"] = {
        "tariff_id" => tariff["tariff_id"],
        "tariff_name" => tariff["tariff_name"],
        "price_amount" => tariff["total_amount"].to_s,
        "price_currency" => tariff["currency"] || "USD",
        "coverage_tier" => normalized["coverage_tier"].to_i,
        "start_date" => normalized["start_date"],
        "end_date" => normalized["end_date"],
        "traveler_count" => normalized["traveler_birth_dates"].size,
        "locality_coverage" => 237
      }

      redirect_to insurance_quote_review_path
    rescue InsursClient::ApiError => e
      redirect_to new_insurance_quote_path, alert: "Could not get a quote: #{e.message}"
    end

    private

    def quote_params
      params.require(:quote).permit(
        :start_date, :end_date, :departure_country, :destination_countries, :coverage_tier,
        destination_countries: [], traveler_birth_dates: []
      )
    end

    def normalize_quote_params
      qp = quote_params.to_h

      # Frontend sends destination_countries as comma-separated string
      if qp["destination_countries"].is_a?(String)
        qp["destination_countries"] = qp["destination_countries"].split(",").map(&:strip).reject(&:blank?)
      end

      qp
    end
  end
end
