FactoryGirl.define do
  factory :order do
    total_quantity 100
    total_price 7600
    distribution_week 0
    status 0
    option_id 2
    distributions { [FactoryGirl.build(:distribution)] }
    store
  end
end