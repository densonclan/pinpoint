class Product < ActiveRecord::Base

  belongs_to :client

  # attr_accessible :title, :body

  #alias :cans? :style?
  #
  #def bottles?
  #  !cans?
  #end

end
