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
      payment = policy.payment_receiveds.order(created_at: :desc).first!

      PolicyRefundInitiated.create!(
        policy_id: policy.id,
        stripe_payment_intent_id: payment.stripe_payment_intent_id,
        reason: params.require(:reason),
        initiated_by_id: Current.identity.id
      )

      redirect_to insurance_policy_path(Current.account.slug, policy), notice: "Refund initiated."
    end
  end
end
