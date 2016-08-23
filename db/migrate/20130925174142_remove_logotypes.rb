class RemoveLogotypes < ActiveRecord::Migration
  def up

    PaperTrail.enabled = false
    
    add_column :stores, :logo, :string
    Store.reset_column_information

    Store.all.each do |store|
      if store.logotype_id
        result = Store.connection.execute "SELECT reference_number FROM logotypes WHERE id=#{store.logotype_id}"
        row = result.first
        if row
          store.logo = row['reference_number']
          store.save
        end
      end
    end

    # remove_column :stores, :logotype_id
    # drop_table :logotypes
  end

  def down
  end
end
