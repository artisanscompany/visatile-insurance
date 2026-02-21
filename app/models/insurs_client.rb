class InsursClient
  BASE_URL = ENV.fetch("INSURS_ONLINE_BASE_URL", "https://api.insurs.net/b1")
  API_KEY = ENV.fetch("INSURS_ONLINE_API_KEY", "")

  PRODUCT_ID = 1
  COMPANY_ID = 366
  FRANCHISE_ID = 1
  COVERAGE_AMOUNTS = { 1 => 35_000, 2 => 100_000, 3 => 500_000 }.freeze

  class ApiError < StandardError; end

  def initialize
    @connection = Faraday.new(url: BASE_URL) do |f|
      f.request :json
      f.response :json, content_type: /\bjson$/
      f.request :retry, max: 3, interval: 2, backoff_factor: 2,
        exceptions: [ Faraday::TimeoutError, Faraday::ConnectionFailed ]
      f.adapter Faraday.default_adapter
    end
  end

  def get_price(start_date:, end_date:, departure_country:, destination_countries:, coverage_tier:, traveler_birth_dates:)
    post("/get_price", {
      product_id: PRODUCT_ID,
      company_id: COMPANY_ID,
      franchise_id: FRANCHISE_ID,
      departure: departure_country,
      arrival: destination_countries,
      locality_coverage: [ 237 ],
      date_from: start_date,
      date_to: end_date,
      coverage_id: COVERAGE_AMOUNTS.fetch(coverage_tier.to_i),
      tourists: traveler_birth_dates.map { |bd| { birthday: bd } }
    })
  end

  def add_contract(policy, travelers)
    first_traveler = travelers.first

    post("/add_contract", {
      product_id: PRODUCT_ID,
      company_id: COMPANY_ID,
      tariff_id: 0,
      departure: policy.departure_country,
      arrival: policy.destination_countries,
      locality_coverage: [ policy.locality_coverage ],
      insurer: {
        last_name: first_traveler.last_name,
        first_name: first_traveler.first_name,
        birthday: first_traveler.birth_date.iso8601,
        phone: "",
        passport_number: first_traveler.passport_number
      },
      tourists: travelers.map { |t|
        {
          last_name: t.last_name,
          first_name: t.first_name,
          birthday: t.birth_date.iso8601,
          passport_number: t.passport_number
        }
      },
      params: {
        date_from: policy.start_date.iso8601,
        date_to: policy.end_date.iso8601,
        coverage_id: policy.coverage_amount,
        franchise_id: FRANCHISE_ID,
        currency_id: 1
      }
    })
  end

  def confirm_contract(order_id)
    post("/confirm_contract", { order_id: order_id })
  end

  def get_print_form(order_id)
    response = @connection.post("/get_print_form", { api_key: API_KEY, order_id: order_id })

    # PDF is returned as raw binary, not JSON
    if response.headers["content-type"]&.include?("application/pdf") || !response.body.is_a?(Hash)
      response.body
    else
      data = response.body
      raise ApiError, data["message"] || "Failed to retrieve PDF" unless data["success"]
      data["data"]
    end
  end

  def cancel_contract(order_id)
    post("/cancel_contract", { order_id: order_id })
  end

  private

  def post(path, body)
    response = @connection.post(path, body.merge(api_key: API_KEY))
    data = response.body
    raise ApiError, data["message"] || "Insurs API error" unless data.is_a?(Hash) && data["success"]
    data["data"]
  end
end
