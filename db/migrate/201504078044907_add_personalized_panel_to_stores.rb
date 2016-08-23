class AddPersonalizedPanelToStores < ActiveRecord::Migration
  def change
    add_column :stores, :personalised_address_panel, :boolean
    add_column :stores, :personalised_panel_1, :boolean
    add_column :stores, :personalised_panel_2, :boolean
    add_column :stores, :personalised_panel_3, :boolean
  end
end
