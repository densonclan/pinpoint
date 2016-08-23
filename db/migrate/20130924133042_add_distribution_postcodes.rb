class AddDistributionPostcodes < ActiveRecord::Migration
  def up
    create_table :distribution_postcodes do |t|
      t.references :distribution
      t.references :postcode_sector
    end
  end

  def down
    drop_table :distribution_postcodes
  end
end
