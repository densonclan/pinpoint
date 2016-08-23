class AddLockedFlagToPeriods < ActiveRecord::Migration
  def change
    add_column :periods, :locked, :boolean
  end
end
