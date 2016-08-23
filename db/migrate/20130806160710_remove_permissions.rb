class RemovePermissions < ActiveRecord::Migration
  def change
    drop_table :permissions
    add_column :users, :user_type, :integer
    add_column :users, :client_id, :integer
    execute "UPDATE users SET user_type=1 WHERE admin=true"
    remove_column :users, :admin
    drop_table :users_roles
  end
end
