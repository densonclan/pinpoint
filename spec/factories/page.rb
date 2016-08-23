FactoryGirl.define do
  factory :page do |f|
    f.name 'Costcutter A'
    f.reference_number 'CC A'
    f.description 'Double spread'
  end

  factory :invalid_page, :class => 'Page' do |f|
    f.name ''
    f.reference_number nil
    f.description 'Double spread'
  end
end