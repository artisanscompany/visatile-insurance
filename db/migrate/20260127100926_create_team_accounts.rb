class CreateTeamAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :team_accounts, id: :uuid do |t|
      t.timestamps
    end
  end
end
