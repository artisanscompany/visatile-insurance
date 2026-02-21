class InsurancePolicy < ApplicationRecord
  include PolicyStateable
  include PolicyFulfillable

  belongs_to :account

  has_many :travelers, dependent: :destroy

  has_many :pending_payments, class_name: "PolicyPendingPayment", foreign_key: :policy_id, dependent: :destroy
  has_many :payment_receiveds, class_name: "PolicyPaymentReceived", foreign_key: :policy_id, dependent: :destroy
  has_many :contract_createds, class_name: "PolicyContractCreated", foreign_key: :policy_id, dependent: :destroy
  has_many :contract_confirmeds, class_name: "PolicyContractConfirmed", foreign_key: :policy_id, dependent: :destroy
  has_many :completeds, class_name: "PolicyCompleted", foreign_key: :policy_id, dependent: :destroy
  has_many :faileds, class_name: "PolicyFailed", foreign_key: :policy_id, dependent: :destroy
  has_many :refund_initiateds, class_name: "PolicyRefundInitiated", foreign_key: :policy_id, dependent: :destroy
  has_many :refundeds, class_name: "PolicyRefunded", foreign_key: :policy_id, dependent: :destroy

  COVERAGE_AMOUNTS = { 1 => 35_000, 2 => 100_000, 3 => 500_000 }.freeze
  COVERAGE_LABELS = { 1 => "Standard", 2 => "Advanced", 3 => "Premium" }.freeze

  scope :recently_created, -> { order(created_at: :desc) }

  def coverage_amount
    COVERAGE_AMOUNTS[coverage_tier]
  end

  def coverage_label
    COVERAGE_LABELS[coverage_tier]
  end
end
