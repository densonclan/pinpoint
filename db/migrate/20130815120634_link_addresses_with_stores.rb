class LinkAddressesWithStores < ActiveRecord::Migration
  def change
    remove_column :addresses, :addressable_id
    remove_column :addresses, :addressable_type
    remove_column :addresses, :updated_by_id
    add_column :addresses, :store_id, :integer

    Address.connection.select_all('SELECT address_id, addressable_id FROM address_assignments').each do |aa|
      a = Address.find_by_id(aa['address_id'])
      if a
        s = Store.find_by_id aa['addressable_id']
        if s
          a.store_id = s.id
          a.save
        else
          puts "No store with ID #{aa['addressable_id']}"
        end
      else
        puts "No address with ID #{aa['address_id']}"
      end
    end

    drop_table :address_assignments
  end
end