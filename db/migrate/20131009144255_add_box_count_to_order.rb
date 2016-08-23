class AddBoxCountToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :total_boxes, :integer
    Order.reset_column_information

    Order.all.each do |o|
      o.total_boxes = 1
      o.save
    end
  end
end