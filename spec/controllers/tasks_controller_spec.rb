# spec/controllers/tasks_controller_spec.rb
require 'spec_helper'

describe TasksController do
  before do
    @controller.should_receive(:authenticate_user!)
    @controller.stub(:update_last_request_stats)
    @controller.stub(:current_user).and_return(@current_user = User.new)
  end

  describe 'index' do
    before do
      @current_user.should_receive(:assigned_tasks_include_departments).and_return(@tasks = double)
      @tasks.should_receive(:unarchived).and_return @tasks
      @tasks.should_receive(:ordered).and_return @tasks
      @tasks.should_receive(:page).with(nil).and_return @tasks
      get :index
    end
    specify { response.should render_template(:index) }
    specify { assigns[:tasks].should == @tasks }
  end

  describe 'assigned' do
    before do
      @current_user.should_receive(:tasks).and_return @tasks = double
      @tasks.should_receive(:unarchived).and_return @tasks
      @tasks.should_receive(:page).with(nil).and_return @tasks
      get :assigned
    end
    specify { response.should render_template(:assigned) }
    specify { assigns[:tasks].should == @tasks }
  end

  describe 'requiring write access' do
    before { @controller.should_receive(:require_write_access) }

    describe 'new' do
      before { get :new, date: '29-08-2013' }
      specify { response.should render_template(:new) }
      specify { assigns[:task].attributes.should == Task.new(due_date: '29-08-2013').attributes }
    end

    describe 'create' do
      before { Task.should_receive(:new_with_user).with('params', @current_user).and_return(@task = double) }
      describe 'successfully' do
        before do
          @task.should_receive(:save).and_return true
          post :create, task: 'params'
        end
        specify { response.should redirect_to(tasks_path) }
        specify { flash[:notice].should == 'Task created successfully' }
      end
      describe 'unsuccessfully' do
        before do
          @task.should_receive(:save).and_return false
          post :create, task: 'params'
        end
        specify { response.should render_template(:new) }
        specify { flash[:error].should == 'Could not save the task.' }
      end
    end
  end

  describe 'actions looking up an individual task' do
    before do
      Task.should_receive(:accessible_by).with(@current_user).and_return(@task = Task.new)
      @task.should_receive(:find).with('65').and_return(@task)
    end
    describe 'requiring write access' do
      before { @controller.should_receive(:require_write_access) }

      describe 'destroy' do
        before { post :destroy, id: 65 }
        specify { response.should redirect_to(tasks_path) }
        specify { flash[:notice].should == 'Task has been deleted.' }
      end

      describe 'archive' do
        before do
          @task.should_receive(:archive!)
          post :archive, id: 65
        end
        specify { response.should redirect_to(tasks_path) }
        specify { flash[:notice].should == 'Task archived.' }
      end

      describe 'unarchive' do
        before do
          @task.should_receive(:unarchive!)
          post :unarchive, id: 65
        end
        specify { response.should redirect_to(tasks_path) }
        specify { flash[:notice].should == 'Task has been restored.' }
      end
    end
    
    describe 'show' do
      before { get :show, id: 65 }
      specify { response.should render_template(:show) }
      specify { assigns[:task].should == @task }
    end
  end
end
          # get 'assigned'
          # get 'calendar'
          # get 'archived'
          # put 'archive/:id', :action => 'archive', :as => 'archive'
          # put 'unarchive/:id', :action => 'unarchive', :as => 'unarchive'
          # get 'store'

