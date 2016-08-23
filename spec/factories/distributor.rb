FactoryGirl.define do
  factory :royal_mail, :class => 'Distributor' do |f|
    f.name 'Royal Mail'
    f.distributor_type 'royal-mail'
    f.description 'asdf'
    f.reference_number 'ROYAL01'
  end

  factory :distributor, :class => 'Distributor' do |f|
    f.name 'Royal Mail'
    f.distributor_type 'royal-mail'
    f.description 'asdf'
    f.reference_number 'ROYAL01'
  end


  factory :invalid_distributor, :class => 'Distributor' do |f|
    f.name nil
    f.distributor_type ''
    f.description ''
    f.reference_number 'DISTRO-01'
  end
end