module PolicyFulfillable
  extend ActiveSupport::Concern

  PDF_STORAGE_DIR = ENV.fetch("PDF_STORAGE_DIR", Rails.root.join("storage/policies").to_s)

  def fulfill!
    return if terminal?

    state_name, _record = failed? ? last_good_state : current_state
    return unless state_name

    client = InsursClient.new

    if state_name == "policy_payment_received"
      create_contract!(client)
      state_name = current_state_name
    end

    if state_name == "policy_contract_created"
      confirm_contract!(client)
      state_name = current_state_name
    end

    if state_name == "policy_contract_confirmed"
      download_pdf!(client)
    end
  end

  def fulfill_later
    PolicyFulfillmentJob.perform_later(self)
  end

  private

  def create_contract!(client)
    result = client.add_contract(self, travelers, tariff_id: coverage_tier)
    PolicyContractCreated.create!(
      policy_id: id,
      insurs_order_id: result["order_id"].to_s,
      insurs_police_num: result["police_num"].to_s,
      total_amount: result["total_amount"].to_s
    )
  rescue => e
    PolicyFailed.create!(policy_id: id, failed_step: "contract_creation", error_message: e.message)
    raise
  end

  def confirm_contract!(client)
    order_id = PolicyContractCreated.where(policy_id: id).order(created_at: :desc).first!.insurs_order_id
    client.confirm_contract(order_id)
    PolicyContractConfirmed.create!(policy_id: id, insurs_order_id: order_id)
  rescue => e
    PolicyFailed.create!(policy_id: id, failed_step: "contract_confirmation", error_message: e.message)
    raise
  end

  def download_pdf!(client)
    order_id = PolicyContractConfirmed.where(policy_id: id).order(created_at: :desc).first!.insurs_order_id
    pdf_bytes = client.get_print_form(order_id)

    FileUtils.mkdir_p(PDF_STORAGE_DIR)
    path = File.join(PDF_STORAGE_DIR, "#{id}.pdf")
    File.binwrite(path, pdf_bytes)

    PolicyCompleted.create!(policy_id: id, pdf_path: path)
    PolicyMailer.confirmation(self).deliver_later
  rescue => e
    PolicyFailed.create!(policy_id: id, failed_step: "pdf_retrieval", error_message: e.message)
    raise
  end
end
