class LandingController < ApplicationController
  disallow_account_scope
  allow_unauthenticated_access

  def show
    render inertia: "Landing/Show", props: {
      coverage_tiers: coverage_tiers,
      panel: params[:panel],
      panel_params: {
        policy_id: params[:policy_id],
        session_id: params[:session_id],
        code: params[:code]
      }.compact
    }
  end

  private

  def coverage_tiers
    InsurancePolicy::COVERAGE_LABELS
  end
end
