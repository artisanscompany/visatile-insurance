# frozen_string_literal: true

module InsurancePolicies
  class PdfDownloadsController < AccountInertiaController
    def show
      policy = Current.account.insurance_policies.find(params[:insurance_policy_id])
      completed = policy.completeds.order(created_at: :desc).first

      if completed&.pdf_path && File.exist?(completed.pdf_path)
        send_file completed.pdf_path,
          filename: "policy-#{policy.id}.pdf",
          type: "application/pdf",
          disposition: "attachment"
      else
        redirect_back fallback_location: insurance_policy_path(Current.account.slug, policy),
          alert: "PDF not yet available."
      end
    end
  end
end
