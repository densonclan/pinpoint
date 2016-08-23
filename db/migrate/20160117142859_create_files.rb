class CreateFiles < ActiveRecord::Migration
  def change
    create_table :uploaded_files do |t|
      t.attachment :file
      t.belongs_to :folder
    end
  end
end
