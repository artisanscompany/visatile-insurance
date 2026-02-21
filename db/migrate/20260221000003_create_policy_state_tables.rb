class CreatePolicyStateTables < ActiveRecord::Migration[8.1]
  def change
    create_table :policy_pending_payments, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :policy, type: :uuid, null: false, foreign_key: { to_table: :insurance_policies }
      t.string :stripe_checkout_session_id, null: false
      t.timestamps
    end

    create_table :policy_payment_receiveds, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :policy, type: :uuid, null: false, foreign_key: { to_table: :insurance_policies }
      t.string :stripe_payment_intent_id, null: false
      t.string :stripe_checkout_session_id, null: false
      t.decimal :amount_received, precision: 10, scale: 2, null: false
      t.string :currency, limit: 3, null: false
      t.timestamps
    end

    create_table :policy_contract_createds, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :policy, type: :uuid, null: false, foreign_key: { to_table: :insurance_policies }
      t.string :insurs_order_id, null: false
      t.string :insurs_police_num, null: false
      t.string :total_amount, limit: 50, null: false
      t.timestamps
    end

    create_table :policy_contract_confirmeds, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :policy, type: :uuid, null: false, foreign_key: { to_table: :insurance_policies }
      t.string :insurs_order_id, null: false
      t.timestamps
    end

    create_table :policy_completeds, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :policy, type: :uuid, null: false, foreign_key: { to_table: :insurance_policies }
      t.string :pdf_path, limit: 512, null: false
      t.timestamps
    end

    create_table :policy_faileds, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :policy, type: :uuid, null: false, foreign_key: { to_table: :insurance_policies }
      t.string :failed_step, limit: 100, null: false
      t.text :error_message, null: false
      t.references :created_by, type: :uuid, foreign_key: { to_table: :identities }, null: true
      t.timestamps
    end

    create_table :policy_refund_initiateds, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :policy, type: :uuid, null: false, foreign_key: { to_table: :insurance_policies }
      t.string :stripe_payment_intent_id, null: false
      t.text :reason, null: false
      t.references :initiated_by, type: :uuid, null: false, foreign_key: { to_table: :identities }
      t.timestamps
    end

    create_table :policy_refundeds, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :policy, type: :uuid, null: false, foreign_key: { to_table: :insurance_policies }
      t.string :stripe_refund_id, null: false
      t.decimal :amount_refunded, precision: 10, scale: 2, null: false
      t.timestamps
    end
  end
end
