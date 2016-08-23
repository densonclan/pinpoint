class AddStatusToPods < ActiveRecord::Migration
  def change
    add_column :pods, :status, :string
  end
end
