FactoryGirl.define do

  factory :distribution do |f|
    f.total_quantity 1200
    f.distribution_week 0
    f.ship_via Distribution::SHIP_VIA_NEP
    f.distributor_id Distribution::IN_STORE
  end

  factory :royal_distribution, :class => 'Distribution' do |f|
    f.total_quantity 1200
    f.contract_number 'S203944'
    f.reference_number '243/344'
    f.distribution_week 0
    f.ship_via Distribution::SHIP_VIA_NEP
    f.after(:build) do |c|
      c.distributor = FactoryGirl.build(:royal_mail) unless c.distributor
      c.order = FactoryGirl.build(:order) unless c.order
    end
  end

  factory :plain_distribution, :class => 'Distribution' do |f|
    f.total_quantity 1200
    f.contract_number 'S203944'
    f.distribution_week 0
    f.ship_via Distribution::SHIP_VIA_NEP
    f.after(:build) do |c|
      c.distributor = FactoryGirl.build(:royal_mail) unless c.distributor
    end
  end

end