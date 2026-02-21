class CreateInsurancePolicies < ActiveRecord::Migration[8.1]
  def change
    create_table :insurance_policies, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :account, type: :uuid, null: false, foreign_key: true
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.string :departure_country, limit: 2, null: false
      t.jsonb :destination_countries, null: false, default: []
      t.integer :locality_coverage, null: false
      t.integer :coverage_tier, null: false
      t.decimal :price_amount, precision: 10, scale: 2, null: false
      t.string :price_currency, limit: 3, null: false, default: "USD"
      t.timestamps
    end

    add_check_constraint :insurance_policies, "coverage_tier BETWEEN 1 AND 3", name: "chk_coverage_tier"
  end
end
