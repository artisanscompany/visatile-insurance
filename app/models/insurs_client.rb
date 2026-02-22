class InsursClient
  BASE_URL = ENV.fetch("INSURS_ONLINE_BASE_URL", "https://api.insurs.net/b1")
  API_KEY = ENV.fetch("INSURS_ONLINE_API_KEY", "")

  PRODUCT_ID = 1
  COMPANY_ID = 366
  FRANCHISE_ID = 1
  COVERAGE_TIERS = { 1 => 1, 2 => 2, 3 => 3, 4 => 4 }.freeze
  COVERAGE_AMOUNTS = { 1 => 35_000, 2 => 100_000, 3 => 500_000, 4 => 1_000_000 }.freeze

  class ApiError < StandardError; end

  def initialize
    base = BASE_URL.end_with?("/") ? BASE_URL : "#{BASE_URL}/"
    @connection = Faraday.new(url: base) do |f|
      f.request :json
      f.response :json, content_type: /\bjson$/
      f.request :retry, max: 3, interval: 2, backoff_factor: 2,
        exceptions: [ Faraday::TimeoutError, Faraday::ConnectionFailed ]
      f.adapter Faraday.default_adapter
    end

    # Separate connection for binary responses (PDF downloads)
    # No JSON response middleware so raw bytes are preserved
    @raw_connection = Faraday.new(url: base) do |f|
      f.request :json
      f.request :retry, max: 3, interval: 2, backoff_factor: 2,
        exceptions: [ Faraday::TimeoutError, Faraday::ConnectionFailed ]
      f.adapter Faraday.default_adapter
    end
  end

  def get_price(start_date:, end_date:, departure_country:, destination_countries: [], coverage_tier:, traveler_birth_dates:, locality_coverage: 237, type_of_travel: 1)
    arrive_country = destination_countries&.first.presence || departure_country
    post("services/api/get_price", {
      product_id: PRODUCT_ID,
      company_id: COMPANY_ID,
      country_of_departure: departure_country,
      country_of_arrive: arrive_country,
      locality_coverage: [ locality_coverage.to_i ],
      additional_services: [ 0 ],
      params: {
        date_from: start_date,
        date_to: end_date,
        coverage_id: coverage_tier.to_i,
        franchise_id: FRANCHISE_ID,
        type_of_travel: type_of_travel.to_i,
        currency: "USD",
        tourists: traveler_birth_dates.map { |bd| { date_birth: bd } }
      }
    })
  end

  def add_contract(policy, travelers, tariff_id: nil, email: nil)
    raise ArgumentError, "At least one traveler is required" if travelers.empty?
    first_traveler = travelers.first
    insurer_email = email || policy.account.identities.first&.email_address || "noreply@example.com"

    post("services/api/add_contract", {
      product_id: PRODUCT_ID,
      company_id: COMPANY_ID,
      tariff_id: tariff_id || policy.coverage_tier,
      country_of_departure: policy.departure_country,
      country_of_arrive: policy.destination_countries&.first.presence || policy.departure_country,
      locality_coverage: [ policy.locality_coverage ],
      insurer: {
        first_name: first_traveler.first_name.upcase,
        last_name: first_traveler.last_name.upcase,
        phone: "0000000000",
        email: insurer_email,
        date_birth: first_traveler.birth_date.iso8601,
        passport: first_traveler.passport_number
      },
      tourists: travelers.map { |t|
        {
          first_name: t.first_name.upcase,
          last_name: t.last_name.upcase,
          date_birth: t.birth_date.iso8601,
          passport: t.passport_number
        }
      },
      params: {
        date_from: policy.start_date.iso8601,
        date_to: policy.end_date.iso8601,
        coverage_id: policy.coverage_tier,
        franchise_id: FRANCHISE_ID,
        type_of_travel: policy.type_of_travel || 1,
        currency: "USD"
      }
    })
  end

  def confirm_contract(order_id)
    post("services/api/confirm_contract", {
      product_id: PRODUCT_ID,
      order_id: order_id,
      payment_id: -1
    })
  end

  def get_print_form(order_id)
    # Use raw connection (no JSON parsing) since response is raw PDF binary
    response = @raw_connection.post("services/api/get_print_form", {
      api_key: API_KEY,
      product_id: PRODUCT_ID,
      order_id: order_id
    })

    body = response.body

    # If it starts with %PDF, it's the raw PDF
    if body.is_a?(String) && body.start_with?("%PDF")
      body
    else
      # Unexpected response — try to parse as JSON error
      begin
        data = JSON.parse(body)
        raise ApiError, data["text_error"] || "Failed to retrieve PDF"
      rescue JSON::ParserError
        # Not JSON and not PDF — return as-is (might be binary PDF without header)
        body
      end
    end
  end

  def cancel_contract(order_id)
    post("services/api/cancel", {
      product_id: PRODUCT_ID,
      order_id: order_id
    })
  end

  private

  def post(path, body)
    response = @connection.post(path, body.merge(api_key: API_KEY))
    data = response.body
    raise ApiError, data["text_error"] || "Insurs API error" unless data.is_a?(Hash) && data["success"]
    data
  end
end
