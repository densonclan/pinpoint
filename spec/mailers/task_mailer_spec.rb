require "spec_helper"

describe TaskMailer do

  describe 'assigned_task_notification' do
    before do
      task = a_pretend :task, id: 13, full_text: 'Get this done!', priority: 1, due_date: Date.new(2013, 10, 26), agent: double('User', name: 'Jonno', email: 'jonno@arctickiwi.com')
      @email = TaskMailer.assigned_task_notification task
    end
    specify { @email.to.should == ['jonno@arctickiwi.com'] }
    specify { @email.from.should == ['pinpoint@gaskandhawley.com'] }
    specify { @email.subject.should == "You have been assigned a Pinpoint task" }
    specify { @email.body.encoded.gsub(/\r\n/, ' ').should match('To Jonno') }
    specify { @email.body.encoded.gsub(/\r\n/, ' ').should match('<label>Priority:</label> High') }
    specify { @email.body.encoded.gsub(/\r\n/, ' ').should match('<label>Due Date:</label> 26 October') }
    specify { @email.body.encoded.should match('<p>Get this done!</p>') }
    specify { @email.body.encoded.include?("<a href=\"#{task_url(13)}\">Click here to view the task on Pinpoint now</a>").should be_true }
  end

  describe 'overdue_task_notification' do
    before do
      task = a_pretend :task, id: 13, full_text: 'Get this done!', priority: 1, due_date: Date.new(2013, 10, 26), agent: double('User', name: 'Jonno', email: 'jonno@arctickiwi.com')
      @email = TaskMailer.overdue_task_notification task
    end
    specify { @email.to.should == ['jonno@arctickiwi.com'] }
    specify { @email.from.should == ['pinpoint@gaskandhawley.com'] }
    specify { @email.subject.should == "You have an overdue Pinpoint task" }
    specify { @email.body.encoded.gsub(/\r\n/, ' ').should match('To Jonno') }
    specify { @email.body.encoded.gsub(/\r\n/, ' ').should match('<label>Priority:</label> High') }
    specify { @email.body.encoded.gsub(/\r\n/, ' ').should match('<label>Due Date:</label> 26 October') }
    specify { @email.body.encoded.should match('<p>Get this done!</p>') }
    specify { @email.body.encoded.include?("<a href=\"#{task_url(13)}\">Click here to view the task on Pinpoint now</a>").should be_true }
  end

  describe 'priority_change_notification' do
    before do
      task = a_pretend :task, id: 13, full_text: 'Get this done!', priority: 1, due_date: Date.new(2013, 10, 26), agent: double('User', name: 'Jonno', email: 'jonno@arctickiwi.com')
      @email = TaskMailer.priority_change_notification task
    end
    specify { @email.to.should == ['jonno@arctickiwi.com'] }
    specify { @email.from.should == ['pinpoint@gaskandhawley.com'] }
    specify { @email.subject.should == 'A Pinpoint task you have been assigned has changed' }
    specify { @email.body.encoded.gsub(/\r\n/, ' ').should match('To Jonno') }
    specify { @email.body.encoded.gsub(/\r\n/, ' ').should match('<label>Priority:</label> High') }
    specify { @email.body.encoded.gsub(/\r\n/, ' ').should match('<label>Due Date:</label> 26 October') }
    specify { @email.body.encoded.should match('<p>Get this done!</p>') }
    specify { @email.body.encoded.include?("<a href=\"#{task_url(13)}\">Click here to view the task on Pinpoint now</a>").should be_true }
  end
end