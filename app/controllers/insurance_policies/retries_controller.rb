# frozen_string_literal: true

module InsurancePolicies
  class RetriesController < AccountInertiaController
    include SuperuserAuthorization
    before_action :require_superuser

    def create
      policy = Current.account.insurance_policies.find(params[:insurance_policy_id])
      policy.fulfill_later
      redirect_to insurance_policy_path(Current.account.slug, policy), notice: "Fulfillment retry initiated."
    end
  end
end
