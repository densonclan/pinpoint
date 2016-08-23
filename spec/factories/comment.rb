FactoryGirl.define do
  factory :comment do |f|
    f.full_text 'The client needs SOLUS next month'
    user
  end


  factory :invalid_comment, :class => 'Comment' do |f|
    f.full_text nil
  end

end