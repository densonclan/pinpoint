class StoresHaveJustOneAddress < ActiveRecord::Migration
  def change
    add_column :stores, :address_id, :integer
    execute "DELETE FROM store_addresses WHERE address_id NOT IN (SELECT id FROM addresses WHERE address_type='store')"
    execute 'UPDATE stores SET address_id=store_addresses.address_id FROM store_addresses WHERE store_addresses.store_id=stores.id'
    drop_table :store_addresses
  end
end