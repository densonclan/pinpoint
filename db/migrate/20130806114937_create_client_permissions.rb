class CreateClientPermissions < ActiveRecord::Migration
  def change
    add_column :users, :admin, :boolean

    execute "UPDATE users SET admin='t' WHERE id IN (SELECT user_id FROM users_roles where role_id=1)"

    drop_table :permissions

    create_table :permissions do |t|
      t.references :user
      t.references :client
      t.string :action
      t.string :subject
    end

    drop_table :roles
  end
end