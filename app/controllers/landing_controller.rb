class LandingController < ApplicationController
  disallow_account_scope
  allow_unauthenticated_access

  def show
    render inertia: "Landing/Show", props: {
      coverage_tiers: coverage_tiers
    }
  end

  private

  def coverage_tiers
    {
      1 => "Standard",
      2 => "Advanced",
      3 => "Premium"
    }
  end
end
