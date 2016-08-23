class OptionsBelongToClients < ActiveRecord::Migration
  def change
    add_column :options, :client_id, :integer

    rename_column :options, :lincensed, :licenced
    rename_column :options, :total_lincensed, :total_licenced

    Option.reset_column_information

    Order.all.each do |order|
      order.reload
      if order.option
        option = Option.find(order.option_id)
        if option.client_id == nil
          puts "Setting order #{order.id} option client ID"
          option.client_id = order.client_id
          option.save
        elsif option.client_id != order.client_id
          puts "Creating new option for order #{order.id}"
          option = Option.create({
            box_quantity: option.box_quantity,
            description: option.description,
            licenced: option.licenced,
            multibuy: option.multibuy,
            name: option.name,
            price_zone: option.price_zone,
            reference_number: option.reference_number,
            total_ambient: option.total_ambient,
            total_licenced: option.total_licenced,
            total_quantity: option.total_quantity,
            total_temp: option.total_temp,
            client_id: order.client_id
          })
          execute "UPDATE orders SET option_id=#{option.id} WHERE option_id=#{order.option_id} AND client_id=#{order.client_id}"
        end
      end
    end
  end
end
