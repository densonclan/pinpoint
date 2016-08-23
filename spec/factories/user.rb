FactoryGirl.define do

  factory :user do
    name 'Bob Doe'
    sequence :email do |n|
      "bob#{n}@example.com"
    end
    password 'bobek32'
    phone '+44 692423321'
    user_type User::ADMIN
    department
  end

  factory :just_user, class: 'User' do
    name 'Bob Doe'
    sequence :email do |n|
      "bob#{n}@example.com"
    end
    password 'bobek32'
    approved true
    phone '+44 692423321'
    user_type User::ADMIN
  end

  factory :user_agent, :class => 'User' do |f|
    f.name 'Bob Doe'
    f.email 'bob2@example.com'
    f.password 'bobek32'
    f.phone '+44 692423321'
    f.user_type User::ADMIN
    f.after(:build) do |u|
      u.department = FactoryGirl.build(:department)
    end
  end

  factory :tasked_user, :class => 'User' do |f|
    f.name 'Bob Doe'
    f.email 'bob3@example.com'
    f.password 'bobek32'
    f.phone '+44 692423321'
    f.user_type User::ADMIN
    f.after(:build) do |u|
      u.department = FactoryGirl.build(:department)
      u.tasks << FactoryGirl.build(:task)
    end
  end

end