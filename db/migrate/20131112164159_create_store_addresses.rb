class CreateStoreAddresses < ActiveRecord::Migration
  def up
    create_table :store_addresses do |t|
      t.integer :store_id
      t.integer :address_id
    end

    execute 'INSERT INTO store_addresses (store_id, address_id) SELECT store_id, id FROM addresses'
    remove_column :addresses, :store_id

  end

  def down
    add_column :addresses, :store_id, :integer
    execute 'UPDATE addresses SET store_id=store_addresses.store_id FROM store_addresses WHERE store_addresses.address_id=addresses.id'
    drop_table :store_addresses

  end
end


def remove_duplicate_addresses

  Address.all.each do |a|
    dup = Address.where(full_name: a.full_name, first_line: a.first_line, second_line: a.second_line, city: a.city, postcode: a.postcode).where('id <> ?', a.id).first
    if dup
      puts "Deleting address #{a.id}"
      Address.connection.execute "UPDATE store_addresses SET address_id=#{dup.id} WHERE address_id=#{a.id}"
      a.destroy
    end
  end
end