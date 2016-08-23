FactoryGirl.define do
  factory :task do |f|
    f.full_text 'Send invoices to Bob'
    f.completed false
    f.for_department false
    f.archived false
    f.completion 0
    f.priority 2
    f.after(:build) do |t|
        f.agent = FactoryGirl.build(:user_agent)
        f.user = FactoryGirl.build(:user)
    end
    f.due_date 5.days.from_now
  end

  factory :invalid_task, :class => "Task" do |f|
    f.full_text nil
    f.completed false
    f.for_department false
    f.archived false
    f.completion 0
    f.priority 2
    f.agent_id nil
    f.after(:build) do |t|
        f.user = FactoryGirl.build(:user)
    end
    f.due_date 5.days.from_now
  end
end