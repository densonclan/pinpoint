class UpdateSequenceNextVal < ActiveRecord::Migration
  def up
    last_value = ActiveRecord::Base.connection.execute("SELECT max(id) as id from periods")[0]["id"].to_i
    ActiveRecord::Base.connection.execute("ALTER SEQUENCE periods_id_seq RESTART WITH #{last_value+1}")
  end

  def down
    # nothing
  end
end
