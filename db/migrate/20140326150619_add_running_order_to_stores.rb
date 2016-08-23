class AddRunningOrderToStores < ActiveRecord::Migration
  def change
    add_column :stores, :running_order, :integer
  end
end
