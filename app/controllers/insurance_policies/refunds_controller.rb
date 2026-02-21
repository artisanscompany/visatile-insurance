# frozen_string_literal: true

module InsurancePolicies
  class RefundsController < AccountInertiaController
    include SuperuserAuthorization
    before_action :require_superuser

    def new
      policy = Current.account.insurance_policies.find(params[:insurance_policy_id])
      render inertia: "InsurancePolicies/Refund/New", props: {
        policy: { id: policy.id, price_amount: policy.price_amount.to_f, price_currency: policy.price_currency }
      }
    end

    def create
      policy = Current.account.insurance_policies.find(params[:insurance_policy_id])
      policy.initiate_refund!(reason: params.require(:reason), identity: Current.identity)

      redirect_to insurance_policy_path(Current.account.slug, policy), notice: "Refund initiated."
    end
  end
end
