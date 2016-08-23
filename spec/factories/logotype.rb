include ActionDispatch::TestProcess
FactoryGirl.define do
  factory :logotype do |f|
    f.title 'Logotype for C9200'
    f.reference_number 'ERFXS23'
    f.image { fixture_file_upload(Rails.root.join('spec', 'files', 'test.png'), 'image/png') }
  end
end