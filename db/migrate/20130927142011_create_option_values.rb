class CreateOptionValues < ActiveRecord::Migration

  def change 

    execute 'DELETE FROM options WHERE client_id IS NULL'

    create_table :option_values do |t|
      t.references :period
      t.references :option
      t.references :page
    end

    execute 'INSERT INTO option_values (period_id, option_id, page_id) SELECT p.id, o.id, page_id FROM periods p, options o WHERE p.client_id=o.client_id'

    remove_column :options, :page_id
  end
end