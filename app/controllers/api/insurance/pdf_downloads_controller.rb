module Api
  module Insurance
    class PdfDownloadsController < Api::BaseController
      def show
        policy = InsurancePolicy.find(params[:policy_id])
        completed = policy.completeds.order(created_at: :desc).first

        if completed&.pdf_path && File.exist?(completed.pdf_path)
          send_file completed.pdf_path,
            filename: "travelskit-policy-#{policy.id}.pdf",
            type: "application/pdf",
            disposition: "attachment"
        else
          render json: { ready: false }, status: :accepted
        end
      end
    end
  end
end
