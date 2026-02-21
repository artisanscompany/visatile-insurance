# frozen_string_literal: true

class CreateInvites < ActiveRecord::Migration[8.1]
  def change
    create_table :invites, id: :uuid do |t|
      t.references :account, type: :uuid, null: false, foreign_key: true
      t.references :inviter, type: :uuid, null: false, foreign_key: { to_table: :users }
      t.string :email, null: false
      t.string :role, null: false, default: "member"
      t.string :token, null: false
      t.datetime :expires_at, null: false
      t.datetime :accepted_at

      t.timestamps
    end

    add_index :invites, :token, unique: true
    add_index :invites, [:account_id, :email], unique: true, where: "accepted_at IS NULL"
  end
end
