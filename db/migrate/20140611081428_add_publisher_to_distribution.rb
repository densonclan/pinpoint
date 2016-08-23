class AddPublisherToDistribution < ActiveRecord::Migration
  def change
    add_column :distributions, :publisher_id, :integer
  end
end
