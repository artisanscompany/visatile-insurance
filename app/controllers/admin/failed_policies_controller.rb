# frozen_string_literal: true

module Admin
  class FailedPoliciesController < AccountInertiaController
    include SuperuserAuthorization
    before_action :require_superuser

    def index
      policies = Current.account.insurance_policies.recently_created.select(&:failed?)

      render inertia: "Admin/FailedPolicies/Index", props: {
        policies: policies.map { |p| serialize_failed_policy(p) }
      }
    end

    private

    def serialize_failed_policy(policy)
      _state_name, record = policy.current_state
      {
        id: policy.id,
        start_date: policy.start_date.iso8601,
        end_date: policy.end_date.iso8601,
        price_amount: policy.price_amount.to_f,
        price_currency: policy.price_currency,
        coverage_label: policy.coverage_label,
        failed_step: record&.failed_step,
        error_message: record&.error_message,
        failed_at: record&.created_at&.iso8601
      }
    end
  end
end
