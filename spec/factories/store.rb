FactoryGirl.define do

  factory :store do
    sequence :account_number do |n|
      "A1111#{n}"
    end
    reference_number 'A08908'
    owner_name 'Jon Doe'
    postcode 'KT10 3YQ'
    client
  end

  factory :just_store, class: 'Store' do
    sequence :account_number do |n|
      "B2222#{n}"
    end
    reference_number 'A08908'
    owner_name 'Jon Doe'
    postcode 'KT10 3YQ'
    preferred_distribution 'Store Delivery'
  end
end