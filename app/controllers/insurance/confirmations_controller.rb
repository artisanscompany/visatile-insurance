# frozen_string_literal: true

module Insurance
  class ConfirmationsController < InsuranceController
    def show
      render inertia: "Insurance/Confirmation/Show", props: {
        policy_id: params[:policy_id],
        session_id: params[:session_id]
      }
    end
  end
end
