class ChangePeriodTimesToDates < ActiveRecord::Migration
  def change
    change_column :periods, :date_promo, :date
    change_column :periods, :date_samples, :date
    change_column :periods, :date_approval, :date
    change_column :periods, :date_print, :date
    change_column :periods, :date_dispatch, :date
    change_column :periods, :date_promo_end, :date
  end
end
