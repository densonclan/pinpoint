class CreatePods < ActiveRecord::Migration
  def up
  	create_table :pods do |p|
		p.string :tracking_number	
		p.datetime :collection_date	
		p.string :reference 		
		p.integer :num_parcels_collected
		p.string :service_level
		p.string :business_name	
		p.string :postcode 	
		p.datetime :delivery_date	
		p.string :delivery_depot 	
		p.integer :num_parcels_delivered 	
		p.string :signature 
		p.timestamps
  	end
	add_index :pods, [:business_name, :postcode]

  end

  def down
  	drop_table :pods
  end
end


