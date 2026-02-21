# frozen_string_literal: true

class InsurancePoliciesController < AccountInertiaController
  def index
    policies = Current.account.insurance_policies.recently_created.map do |policy|
      serialize_policy_summary(policy)
    end

    render inertia: "InsurancePolicies/Index", props: {
      policies: policies
    }
  end

  def show
    policy = Current.account.insurance_policies.find(params[:id])

    render inertia: "InsurancePolicies/Show", props: {
      policy: serialize_policy_detail(policy),
      travelers: policy.travelers.map { |t| serialize_traveler(t) },
      current_state: policy.current_state_name,
      state_history: policy.state_history.map { |h| serialize_state_entry(h) }
    }
  end

  private

  def serialize_policy_summary(policy)
    {
      id: policy.id,
      start_date: policy.start_date.iso8601,
      end_date: policy.end_date.iso8601,
      departure_country: policy.departure_country,
      destination_countries: policy.destination_countries,
      coverage_tier: policy.coverage_tier,
      coverage_label: policy.coverage_label,
      price_amount: policy.price_amount.to_f,
      price_currency: policy.price_currency,
      current_state: policy.current_state_name,
      created_at: policy.created_at.iso8601
    }
  end

  def serialize_policy_detail(policy)
    serialize_policy_summary(policy).merge(
      locality_coverage: policy.locality_coverage
    )
  end

  def serialize_traveler(traveler)
    {
      id: traveler.id,
      first_name: traveler.first_name,
      last_name: traveler.last_name,
      birth_date: traveler.birth_date.iso8601,
      passport_number: traveler.passport_number,
      passport_country: traveler.passport_country
    }
  end

  def serialize_state_entry(entry)
    {
      state: entry[:state],
      created_at: entry[:created_at].iso8601,
      details: entry[:record].attributes.except("id", "policy_id", "created_at", "updated_at")
    }
  end
end
