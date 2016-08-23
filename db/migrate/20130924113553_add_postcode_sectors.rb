class AddPostcodeSectors < ActiveRecord::Migration
  def up
    create_table :postcode_sectors do |t|
      t.string :area, limit: 2
      t.integer :district
      t.integer :sector
      t.integer :residential
      t.integer :business
      t.string :zone, limit: 2
      t.timestamps
    end
  end

  def down
    drop_table :postcode_sectors
  end
end
