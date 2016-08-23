FactoryGirl.define do
  factory :option do
    name 'SG - Nisa'
    description 'Nisa'
    reference_number 'SG'
    price_zone 'Convenience'
    multibuy true
    licenced true
    total_ambient 24
    total_licenced 10
    total_temp 16
    client
  end
end