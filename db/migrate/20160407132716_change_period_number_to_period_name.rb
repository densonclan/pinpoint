class ChangePeriodNumberToPeriodName < ActiveRecord::Migration
  def up
    change_column :periods, :period_number, :string, default: "0"
  end

  def down
    change_column :periods, :period_number, :integer, default: 0
  end
end
