module WillPaginate

  def paginated_collection_of(what, how_many = 2)
    arr = []
    how_many.times do |i|
      o = FactoryGirl.build(what)
      o.stub(:id).and_return(i+1)
      arr << o
    end
    arr.stub(:total_pages).and_return 1
    arr.paginate
    arr
  end
end

RSpec.configure do |config|
  config.include WillPaginate, type: :view
end