class AddShipViaToDistributions < ActiveRecord::Migration
  def change
    add_column :distributions, :ship_via, :string
    execute "UPDATE distributions SET ship_via='NEP' WHERE distributor_id=1"
    execute "UPDATE distributions SET ship_via='G&H' WHERE distributor_id<>1"
  end
end
