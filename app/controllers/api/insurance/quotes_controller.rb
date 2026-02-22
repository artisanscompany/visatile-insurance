# frozen_string_literal: true

module Api
  module Insurance
    class QuotesController < Api::BaseController
      def create
        client = InsursClient.new
        normalized = normalize_quote_params
        price_params = normalized.symbolize_keys.slice(
          :start_date, :end_date, :departure_country, :destination_countries,
          :coverage_tier, :traveler_birth_dates, :locality_coverage, :type_of_travel
        ).compact
        result = client.get_price(**price_params)
        tariff = result["data"].first

        render json: {
          quote_request: normalized,
          quote_response: {
            tariff_id: tariff["tariff_id"],
            tariff_name: tariff["tariff_name"],
            price_amount: tariff["total_amount"].to_s,
            price_currency: tariff["currency"] || "USD",
            coverage_tier: normalized["coverage_tier"].to_i,
            start_date: normalized["start_date"],
            end_date: normalized["end_date"],
            traveler_count: normalized["traveler_birth_dates"].size,
            locality_coverage: (normalized["locality_coverage"] || 237).to_i
          }
        }
      rescue InsursClient::ApiError => e
        render json: { error: "Could not get a quote: #{e.message}" }, status: :unprocessable_entity
      end

      private

      def quote_params
        params.require(:quote).permit(
          :start_date, :end_date, :departure_country, :destination_countries, :coverage_tier,
          :locality_coverage, :type_of_travel,
          destination_countries: [], traveler_birth_dates: []
        )
      end

      def normalize_quote_params
        qp = quote_params.to_h

        if qp["destination_countries"].is_a?(String)
          qp["destination_countries"] = qp["destination_countries"].split(",").map(&:strip).reject(&:blank?)
        end

        qp
      end
    end
  end
end
