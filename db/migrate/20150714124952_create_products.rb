class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products, id: false do |t|
      t.integer    :id, options: 'PRIMARY KEY', null: false
      t.references :client
      t.string     :name,                       null: false
      t.string     :description
      t.boolean    :bottles, default: false,    null: false
      t.boolean    :fridge,  default: false,    null: false
      t.timestamps
    end

    add_index :products, :client_id
  end
end
