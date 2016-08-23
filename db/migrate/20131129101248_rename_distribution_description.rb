class RenameDistributionDescription < ActiveRecord::Migration
  def up
    rename_column :distributions, :description, :notes
    add_index :store_addresses, :store_id
  end

  def down
    rename_column :distributions, :notes, :description
    remove_index :store_addresses, :store_id
  end
end
