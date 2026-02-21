class AddExpiresAtToSessions < ActiveRecord::Migration[8.1]
  def change
    add_column :sessions, :expires_at, :datetime

    # Set expiration for existing sessions (30 days from now)
    reversible do |dir|
      dir.up do
        Session.update_all(expires_at: 30.days.from_now)
      end
    end

    change_column_null :sessions, :expires_at, false
    add_index :sessions, :expires_at
  end
end
