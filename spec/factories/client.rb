FactoryGirl.define do
  factory :client do
    sequence :name do |n|
      "NISA #{n}"
    end
    sequence :code do |n|
      "NISA-0#{n}"
    end

    description 'Nisa chain of stores'
    reference 'NISA01'
  end

  factory :invalid_client, :class => 'Client'  do |f|
    f.name ''
    f.description 'Nisa chain of stores'
    f.reference 'NISA01'
    f.code nil
  end

end