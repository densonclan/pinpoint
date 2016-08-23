# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :message do
    full_text "MyString"
    subject "New message notification from User"
    read false
    read_at nil
    archived false
  end
end
