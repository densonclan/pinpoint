class OrderException < ActiveRecord::Base

  belongs_to :period
  belongs_to :order
end