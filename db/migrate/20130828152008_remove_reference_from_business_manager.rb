class RemoveReferenceFromBusinessManager < ActiveRecord::Migration
  def up
    remove_column :business_managers, :reference_number
    remove_column :business_managers, :phone_number
    add_column :business_managers, :phone_number, :string
  end

  def down
    add_column :business_managers, :reference_number, :string
  end
end
