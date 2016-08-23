class AddAddressToDistribution < ActiveRecord::Migration
  def change
    add_column :distributions, :address_id, :integer
  end
end
