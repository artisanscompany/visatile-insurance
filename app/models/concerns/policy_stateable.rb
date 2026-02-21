module PolicyStateable
  extend ActiveSupport::Concern

  STATE_MODELS = [
    { name: "policy_refunded",           model_name: "PolicyRefunded" },
    { name: "policy_refund_initiated",   model_name: "PolicyRefundInitiated" },
    { name: "policy_failed",             model_name: "PolicyFailed" },
    { name: "policy_completed",          model_name: "PolicyCompleted" },
    { name: "policy_contract_confirmed", model_name: "PolicyContractConfirmed" },
    { name: "policy_contract_created",   model_name: "PolicyContractCreated" },
    { name: "policy_payment_received",   model_name: "PolicyPaymentReceived" },
    { name: "policy_pending_payment",    model_name: "PolicyPendingPayment" }
  ].freeze

  TERMINAL_STATES = %w[policy_completed policy_refunded policy_refund_initiated].freeze

  def current_state
    latest_record = nil
    latest_name = nil

    STATE_MODELS.each do |entry|
      record = entry[:model_name].constantize
        .where(policy_id: id).order(created_at: :desc).first
      if record && (latest_record.nil? || record.created_at > latest_record.created_at)
        latest_record = record
        latest_name = entry[:name]
      end
    end

    latest_name ? [ latest_name, latest_record ] : nil
  end

  def current_state_name
    current_state&.first
  end

  def state_history
    STATE_MODELS.flat_map do |entry|
      entry[:model_name].constantize.where(policy_id: id).map do |record|
        { state: entry[:name], record: record, created_at: record.created_at }
      end
    end.sort_by { |h| h[:created_at] }
  end

  def terminal?
    TERMINAL_STATES.include?(current_state_name)
  end

  def failed?
    current_state_name == "policy_failed"
  end

  def completed?
    current_state_name == "policy_completed"
  end

  def last_good_state
    history = state_history.reject { |h| h[:state] == "policy_failed" }
    entry = history.last
    entry ? [ entry[:state], entry[:record] ] : nil
  end
end
