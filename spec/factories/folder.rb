FactoryGirl.define do
  factory :folder do |f|
    f.user { FactoryGirl.create(:user) }
    f.name { "folder_name" }
  end
end