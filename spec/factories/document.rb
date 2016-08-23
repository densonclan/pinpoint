FactoryGirl.define do
  factory :document do
    title 'C0124 - Raport 2012'
    # file { fixture_file_upload(Rails.root.join('spec', 'files', 'map.png'), 'image/png') }
    # user
    #association :store, factory: :just_store, strategy: :build
  end
end