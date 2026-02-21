class CreateTravelers < ActiveRecord::Migration[8.1]
  def change
    create_table :travelers, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :insurance_policy, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.date :birth_date, null: false
      t.string :passport_number, limit: 50, null: false
      t.string :passport_country, limit: 2, null: false
      t.timestamps
    end
  end
end
