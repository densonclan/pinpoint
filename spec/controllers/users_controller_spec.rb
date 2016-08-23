require 'spec_helper'

describe UsersController do

  before do
    @controller.should_receive :authenticate_user!
    @controller.should_receive :require_admin
    @controller.stub :update_last_request_stats
  end

  describe "index" do
    before do
      User.should_receive(:with_client).and_return @users = double
      @users.should_receive(:ordered).and_return @users
      get :index
    end
    specify { response.should render_template(:index) }
    specify { assigns[:users].should == @users }
  end

  describe 'actions requiring a user' do
    before { User.should_receive(:find).with('12').and_return(@user = User.new) }

    describe "edit" do
      before { get :edit, {id: 12} }
      specify { response.should render_template(:edit) }
    end

    describe 'update' do
      describe 'successfully' do
        before do
          @user.should_receive(:update_attributes).with('params').and_return true
          post :update, id: 12, user: 'params'
        end
        specify { response.should redirect_to(users_path) }
        specify { flash[:notice].should == 'User saved successfully' }
      end
      describe 'unsuccessfully' do
        before do
          @user.should_receive(:update_attributes).with('params').and_return false
          post :update, id: 12, user: 'params'
        end
        specify { response.should render_template(:edit) }
        specify { flash[:error].should == 'Error saving user' }
      end
    end

    describe "activate" do
      describe 'successfully' do
        before do
          @user.should_receive(:activate!).and_return true
          post :activate, {id: 12}
        end
        specify { response.should redirect_to(users_path) }
        specify { flash[:notice].should == 'User activated successfully' }
      end
      describe 'unsuccessfully' do
        before do
          @user.should_receive(:activate!).and_return false
          post :activate, {id: 12}
        end
        specify { response.should redirect_to(users_path) }
        specify { flash[:error].should == 'Unable to activate user - check they belong to a client' }
      end
    end

    describe "deactivate" do
      before do
        @user.should_receive(:deactivate!)
        post :deactivate, {id: 12}
      end
      specify { response.should redirect_to(users_path) }
      specify { flash[:notice].should == 'User deactivated successfully' }
    end
  end
end