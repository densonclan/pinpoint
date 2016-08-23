require 'spec_helper'

describe Comment do

  before { Task.any_instance.stub(:send_notification_email) }
  
  describe "new_from_user" do
    before do
      @params = {commentable_id: 5, commentable_type: 'Report', full_text: 'oh yeah!', department_id: 67, save_as_task: 1, assignee_id: 54, due_date: '06/12/2013'}
      @user = User.new
      @user.stub(:id).and_return(44)
      @comment = Comment.new_from_user(@params, @user)
    end
    specify { @comment.commentable_id.should == 5 }
    specify { @comment.commentable_type.should == 'Report' }
    specify { @comment.full_text.should == 'oh yeah!' }
    specify { @comment.user_id.should == 44 }
    specify { @comment.due_date.should == '06/12/2013' }
  end

  describe "save should create task" do
    let(:store) { create_a(:store) }
    describe 'for department' do
      before do
        @user = FactoryGirl.create(:user)
        @params = {commentable_id: store.id, commentable_type: 'Store', full_text: 'oh yeah!', department_id: 67, save_as_task: 1, due_date: '14/12/2017', user_id: @user.id}
        @comment = Comment.new(@params)
        @comment.save
        @task = Task.last
      end
      specify { @comment.should_not be_new_record }
      specify { @task.full_text.should == 'oh yeah!' }
      specify { @task.department_id.should == 67 }
      specify { @task.user_id.should == @user.id }
      specify { @task.due_date.strftime('%Y-%m-%d').should == '2017-12-14' }
      specify { @task.agent_id.should be_nil }
      specify { @task.store.should == store }
    end

    describe 'for user' do
      let(:order) { create_a(:order, store: store) }
      before do
        @user = FactoryGirl.create(:user)
        @params = {commentable_id: order.id, commentable_type: 'Order', full_text: 'oh yeah!', save_as_task: 1, assignee_id: 54, due_date: '14/12/2017', user_id: @user.id}
        @comment = Comment.new(@params)
        @comment.save
        @task = Task.last
      end
      specify { @comment.should_not be_new_record }
      specify { @task.full_text.should == 'oh yeah!' }
      specify { @task.department_id.should be_nil }
      specify { @task.user_id.should == @user.id }
      specify { @task.due_date.strftime('%Y-%m-%d').should == '2017-12-14' }
      specify { @task.agent_id.should == 54 }
      specify { @task.store.should == store }
    end
  end

  describe "validations" do
    before do
      @comment = Comment.new commentable_type: 'Store', commentable_id: create_a(:store).id
      @comment.user = create_a(:user)
    end
    describe 'valid' do
      specify { @comment.should be_valid }
    end
    describe 'invalid' do
      describe 'commentable type' do
        before { @comment.commentable_type = 'Stores' }
        specify { @comment.should_not be_valid }
      end
      describe 'missing user' do
        before { @comment.user = nil }
        specify { @comment.should_not be_valid }
      end
      describe 'commentable ID' do
        before { @comment.commentable_id = 9 }
        specify { @comment.should_not be_valid }
      end
    end

    describe 'commentable permission' do
      # validate commentable.client_id = user.client_id
      pending
    end
  end
end