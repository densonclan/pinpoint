class AddStoreUrgentToStore < ActiveRecord::Migration
  def change
    add_column :stores, :store_urgent, :boolean
  end
end
