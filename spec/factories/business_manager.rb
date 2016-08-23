FactoryGirl.define do
  factory :business_manager do
    sequence :name do |n|
      "Costcutter #{n}"
    end
    sequence :email do |s|
      "cost#{s}@costcutter.co.uk"
    end
    phone_number 7944762377
  end
end