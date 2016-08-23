# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :postcode_sector_transport, class: 'Transport' do
    transport_type 'PostcodeSector'
    status Transport::PENDING

    spreadsheet { File.new(Rails.root.join('spec/files/postcode_sector_transport.csv')) }
  end
end
