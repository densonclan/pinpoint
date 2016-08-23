class FixInvalidData < ActiveRecord::Migration
  def up
    change_column :tasks, :due_date, :date

    Order.includes(:period, :option, :store).each do |order|
      if order.period && order.client_id != order.period.client_id
        puts "Order #{order.id} period client ID mismatch"
        period = Period.where(client_id: order.client_id, period_number: order.period.period_number).first
        Order.connection.execute "UPDATE orders SET period_id=#{period.id} WHERE id=#{order.id}"
      end
      if order.option && order.client_id != order.option.client_id
        puts "Order #{order.id} option client ID mismatch"
        option = Option.where(client_id: order.client_id, name: order.option.name).first
        Order.connection.execute "UPDATE orders SET option_id=#{option.id} WHERE id=#{order.id}"
      end
    end
  end

  def down
  end
end