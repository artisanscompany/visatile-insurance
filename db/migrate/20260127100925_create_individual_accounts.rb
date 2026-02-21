class CreateIndividualAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :individual_accounts, id: :uuid do |t|
      t.timestamps
    end
  end
end
