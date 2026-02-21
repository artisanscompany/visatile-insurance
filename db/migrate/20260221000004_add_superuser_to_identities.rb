class AddSuperuserToIdentities < ActiveRecord::Migration[8.1]
  def change
    add_column :identities, :superuser, :boolean, default: false, null: false
  end
end
