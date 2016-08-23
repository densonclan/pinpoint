class AddParticipationOnlyToStores < ActiveRecord::Migration
  def change
    add_column :stores, :participation_only, :boolean
  end
end
