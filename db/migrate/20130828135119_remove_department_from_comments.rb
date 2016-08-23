class RemoveDepartmentFromComments < ActiveRecord::Migration
  def up
    remove_column :comments, :department_id
  end

  def down
    add_column :comments, :department_id, :integer
  end
end
