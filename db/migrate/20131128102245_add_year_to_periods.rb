class AddYearToPeriods < ActiveRecord::Migration
  def change
    add_column :periods, :year, :integer

    execute 'UPDATE periods SET year=2013'
    execute 'UPDATE periods SET year=2014 WHERE id BETWEEN 66 AND 104'
  end
end
