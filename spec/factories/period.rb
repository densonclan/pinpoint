FactoryGirl.define do
  factory :period do
    sequence :id
    period_number 1
    week_number 242
    year 2014
    current true
    date_promo 3.days.from_now
    date_promo_end 30.days.from_now
    date_samples 5.days.from_now
    date_approval 6.days.from_now
    date_print 6.days.from_now
    date_dispatch 10.days.from_now
    client
  end
end
