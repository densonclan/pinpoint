class ChangeDistributions < ActiveRecord::Migration
  def change
    change_column_default :distributions, :total_quantity, nil
    change_column_default :distributions, :total_boxes, nil
    change_column_default :distributions, :distribution_week, nil
  end
end