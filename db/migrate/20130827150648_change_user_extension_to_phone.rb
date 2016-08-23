class ChangeUserExtensionToPhone < ActiveRecord::Migration
  def up
    rename_column :users, :extention, :phone
    change_column :users, :phone, :string
    change_column_default :users, :phone, nil
  end

  def down
  end
end
