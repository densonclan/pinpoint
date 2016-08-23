# ./spec/models/task_spec.rb
require 'spec_helper'

describe Task do

  before(:each) do
    @task = FactoryGirl.build(:task)
    ActionMailer::Base.deliveries.clear
  end

  it 'should have valid Factory' do
    @task.should be_valid
  end

  it 'should not be vald without a content' do
    @task.full_text = nil
    @task.should_not be_valid
  end

  it 'should have completion level within the limit' do
    @task.completion = 0
    @task.should be_valid
  end

  it 'should not be valid with completion out the limit' do
    @task.completion = -10
    @task.should_not be_valid
    @task.completion = 123
    @task.should_not be_valid
  end

  it 'should have valid priority value' do
    @task.priority = 3
    @task.should_not be_valid
    @task.priority = -12
    @task.should_not be_valid
  end

  it 'should have the due date greater than today' do
    @task.due_date = 1.day.ago
    @task.should_not be_valid
  end

  it { should belong_to(:user) }

  describe 'archive!' do
    before do
      @task = FactoryGirl.create(:task)
      @task.archive!
    end
    specify { @task.reload.archived.should be_true }
  end

  describe 'unarchive!' do
    before do
      @task = FactoryGirl.create(:task, archived: true)
      @task.unarchive!
    end
    specify { @task.reload.archived.should be_false }
  end

  describe 'accessible_by' do
    before do
      @tasks = [
        @task1 = FactoryGirl.create(:task, agent_id: 4), 
        @task2 = FactoryGirl.create(:task, user_id: 4), 
        @task3 = FactoryGirl.create(:task, department_id: 5, for_department: true), 
        @task4 = FactoryGirl.create(:task, agent_id: 5), 
        @task5 = FactoryGirl.create(:task, user_id: 5)
      ]
    end
    describe 'for internal user' do
      before { @user = double(internal?: true) }
      specify { Task.accessible_by(@user).should == @tasks }
    end
    describe 'for client' do
      before { @user = double(internal?: false, id: 4, department_id: 5) }
      specify { Task.accessible_by(@user).should == [@task1, @task2, @task3]}
    end
  end

  describe 'scopes' do
    describe 'due_today' do
      before do
        @task1 = create_a(:task, due_date: 2.days.ago)
        @task2 = create_a(:task, due_date: Date.yesterday)
        @task3 = create_a(:task, due_date: Date.today)
      end
      specify { Task.due_yesterday.should == [@task2] }
    end
    describe 'assigned_to_a_user' do
      before do
        @task1 = create_a(:task, agent_id: 12)
        @task2 = create_a(:task, agent_id: nil)
      end
      specify { Task.assigned_to_a_user.should == [@task1] }
    end
  end

  describe 'notify_overdue_tasks' do
    before do
      user = create_a(:just_user)
      task1 = create_a(:task, due_date: Date.yesterday, agent_id: user.id, archived: true)
      task2 = create_a(:task, due_date: Date.yesterday, agent_id: user.id, archived: false)
      task3 = create_a(:task, due_date: Date.yesterday, agent_id: nil)
      task4 = create_a(:task, due_date: 2.days.ago, agent_id: user.id, archived: false)
      task5 = create_a(:task, due_date: Date.today, agent_id: user.id, archived: false)
      TaskMailer.should_receive(:overdue_task_notification).with(task2).and_return(double('Mailer', deliver: 'OK!'))
      TaskMailer.should_not_receive(:overdue_task_notification).with(task1)
      TaskMailer.should_not_receive(:overdue_task_notification).with(task3)
      TaskMailer.should_not_receive(:overdue_task_notification).with(task4)
      TaskMailer.should_not_receive(:overdue_task_notification).with(task5)
    end
    specify { Task.notify_overdue_tasks.should be_true }
  end

  describe 'send_status_change_email' do
    before { @task = Task.create(agent_id: create_a(:just_user).id, due_date: '2018-01-20', completion: 0, priority: 1, full_text: 'test task') }
    describe 'without a change in status' do
      before do
        @task.priority = 2
        @task.save
      end
      specify { ActionMailer::Base.deliveries.length.should == 1 }
    end
    describe 'with a change in status' do
      before do
        @task.completion = 50
        @task.save
      end
      specify { ActionMailer::Base.deliveries.length.should == 2 }
      specify { ActionMailer::Base.deliveries.last.subject.should == 'A Pinpoint task you have been assigned has changed' }
    end
  end    

  describe 'send_notification_email' do
    describe 'after create' do
      describe 'with agent' do
        before { Task.create(agent_id: create_a(:just_user).id, due_date: '2018-01-20', completion: 0, priority: 1, full_text: 'test task') }
        specify { ActionMailer::Base.deliveries.length.should == 1 }
        specify { ActionMailer::Base.deliveries.first.subject.should == 'You have been assigned a Pinpoint task' }
      end
      describe 'without agent' do
        before { Task.create(due_date: '2018-01-20', completion: 0, priority: 1, full_text: 'test task') }
        specify { ActionMailer::Base.deliveries.length.should == 0 }
      end
    end
    describe 'after update' do
      describe 'with new agent' do
        before do
          task = Task.create(agent_id: create_a(:just_user).id, due_date: '2018-01-20', completion: 0, priority: 1, full_text: 'test task')
          task.agent_id = create_a(:just_user, name: 'Sam', email: 'sam@smith.com').id
          task.save
        end
        specify { ActionMailer::Base.deliveries.length.should == 2 }
        specify { ActionMailer::Base.deliveries.last.to.should == ['sam@smith.com'] }
      end
      describe 'with same agent' do
        before do
          user = create_a(:just_user)
          task = Task.create(agent_id: user.id, due_date: '2018-01-20', completion: 0, priority: 1, full_text: 'test task')
          task.full_text = 'something else'
          task.save
        end
        specify { ActionMailer::Base.deliveries.length.should == 1 }
      end
      describe 'with agent removed' do
        before do
          task = Task.create(agent_id: create_a(:just_user).id, due_date: '2018-01-20', completion: 0, priority: 1, full_text: 'test task')
          task.agent_id = nil
          task.save
        end
        specify { ActionMailer::Base.deliveries.length.should == 1 }
      end
    end
  end
end