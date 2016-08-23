class CreateRecordLock < ActiveRecord::Migration
  def up
    create_table :record_locks do |r|
      r.string :record_type
      r.integer :record_id
      r.references :user
      r.datetime :created_at
    end

    add_index :record_locks, [:record_type, :record_id]
  end

  def down
    drop_table :record_locks
  end
end
