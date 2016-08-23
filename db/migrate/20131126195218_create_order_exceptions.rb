class CreateOrderExceptions < ActiveRecord::Migration
  def up
    create_table :order_exceptions do |t|
      t.integer :period_id
      t.integer :order_id
    end
  end

  def down
    drop_table :order_exceptions
  end
end
