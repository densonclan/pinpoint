class AddPreferredOptionToStores < ActiveRecord::Migration
  def change
    add_column :stores, :preferred_option_id, :integer
  end
end
