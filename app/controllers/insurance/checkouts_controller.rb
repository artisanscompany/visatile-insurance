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
      email = params.require(:email).strip.downcase
      quote_req = insurance_session["quote_request"]
      quote_resp = insurance_session["quote_response"]
      travelers_data = insurance_session["travelers"]

      identity = Identity.find_or_create_by!(email_address: email)
      account = identity.accounts.first || Account.create_individual_for(
        identity: identity,
        user_name: email.split("@").first,
        account_name: "Personal"
      )

      policy = account.insurance_policies.create!(
        start_date: quote_req["start_date"],
        end_date: quote_req["end_date"],
        departure_country: quote_req["departure_country"],
        destination_countries: quote_req["destination_countries"],
        locality_coverage: quote_resp["locality_coverage"] || 237,
        coverage_tier: quote_req["coverage_tier"].to_i,
        price_amount: quote_resp["price_amount"],
        price_currency: quote_resp["price_currency"] || "USD"
      )

      travelers_data.each do |t|
        policy.travelers.create!(t.symbolize_keys)
      end

      stripe_session = ::Stripe::Checkout::Session.create(
        payment_method_types: [ "card" ],
        mode: "payment",
        customer_email: email,
        line_items: [ {
          price_data: {
            currency: policy.price_currency.downcase,
            product_data: { name: "Travel Insurance - #{policy.coverage_label}" },
            unit_amount: (policy.price_amount * 100).to_i
          },
          quantity: 1
        } ],
        metadata: { policy_id: policy.id },
        success_url: "#{request.base_url}/insurance/confirmation?session_id={CHECKOUT_SESSION_ID}&policy_id=#{policy.id}",
        cancel_url: "#{request.base_url}/insurance/checkout/new"
      )

      PolicyPendingPayment.create!(
        policy_id: policy.id,
        stripe_checkout_session_id: stripe_session.id
      )

      session.delete(:insurance_flow)

      redirect_to stripe_session.url, allow_other_host: true
    end
  end
end
