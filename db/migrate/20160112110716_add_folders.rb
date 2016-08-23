class AddFolders < ActiveRecord::Migration
  def change
    create_table :folders do |t|
      t.string :name, null: false
      t.integer :parent_id
      t.references :user

      t.timestamps
    end

    add_index :folders, :user_id
    add_index :folders, :parent_id
  end
end
