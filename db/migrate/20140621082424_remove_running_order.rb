class RemoveRunningOrder < ActiveRecord::Migration
  def up
    remove_column :stores, :running_order
  end

  def down
    add_column :stores, :running_order, :integer
  end
end
