class RenameTransportFileField < ActiveRecord::Migration
  def change
    rename_column :transports, :file_path, :spreadsheet_file_name
    add_column :transports, :status, :integer

    execute 'DELETE FROM transports'
  end
end