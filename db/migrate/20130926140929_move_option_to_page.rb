class MoveOptionToPage < ActiveRecord::Migration
  def up
    add_column :pages, :box_quantity, :integer
    execute "UPDATE pages SET box_quantity=500 WHERE id IN (1,2)"
    execute "UPDATE pages SET box_quantity=250 WHERE id IN (3,4)"
    Page.reset_column_information
    Page.create(name: 'A4 6 Pages Crossfold', reference_number: 'A4-06C', box_quantity: 250)
    add_column :options, :page_id, :integer
    execute 'UPDATE options SET page_id=1'
    remove_column :options, :box_quantity
    remove_column :orders, :page_id
  end

  def down
  end
end
