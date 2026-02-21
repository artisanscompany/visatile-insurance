class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users, id: :uuid do |t|
      t.references :identity, type: :uuid, null: false, foreign_key: true
      t.references :account, type: :uuid, null: false, foreign_key: true
      t.string :name, null: false
      t.string :role, default: "member"

      t.timestamps
    end

    add_index :users, [:identity_id, :account_id], unique: true
  end
end
