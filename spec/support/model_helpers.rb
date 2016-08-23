module ModelHelpers

  def a_pretend(what, values = {})
    o = eval(what.to_s.camelcase).new
    FactoryGirl.attributes_for(what).each do |k,v|
      o.send("#{k}=".to_sym, v)
    end
    values[:id] = 5 unless values[:id]
    values[:persisted?] = true
    o.stub(values)
    o
  end

  def create_a(what, values = {})
    o = FactoryGirl.build(what, values)
    o.save(validate: false)
    o
  end

  def delete_all(tables)
    tables.each {|t| Store.connection.execute("DELETE FROM #{t}") }
    ActionMailer::Base.deliveries.clear
  end
end