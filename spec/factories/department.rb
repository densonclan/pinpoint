FactoryGirl.define do
  factory :department do |f|
    f.name 'Administrator'
    f.short_code 'administrator'
    f.description 'Administrator Group'
  end

  factory :new_department, :class => 'Department' do |f|
    f.name 'Nisa'
    f.short_code 'nisa'
    f.description 'Nisa Group'
  end

  factory :invalid_department, :class => 'Department' do |f|
    f.name ''
    f.short_code nil
    f.description 'Group'
  end
end