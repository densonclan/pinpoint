class CreateSharedFolders < ActiveRecord::Migration
  def change
    create_table :shared_folders do |t|
      t.belongs_to :user
      t.belongs_to :folder

      t.timestamps
    end
  end
end
