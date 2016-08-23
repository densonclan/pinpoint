class RemoveTotalBoxesFromOrders < ActiveRecord::Migration
  def change
    remove_column :orders, :total_boxes
    remove_column :distributions, :total_boxes
  
    execute 'delete from option_values where  period_id not in (select id from periods)'

    Option.all.each do |option|
      Period.where(client_id: option.client_id).each do |period|
        value = OptionValue.where(option_id: option.id, period_id: period.id).first
        OptionValue.create(option: option, period: period) if value.nil?
      end
    end
  end
end
