class CreateAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :accounts, id: :uuid do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :accountable_type
      t.uuid :accountable_id

      t.timestamps
    end

    add_index :accounts, :slug, unique: true
    add_index :accounts, [:accountable_type, :accountable_id]
  end
end
