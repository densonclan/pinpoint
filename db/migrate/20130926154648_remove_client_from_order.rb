class RemoveClientFromOrder < ActiveRecord::Migration
  def up
    remove_column :orders, :client_id
  end

  def down
  end
end
