# spec/controllers/dashboard_controller_spec.rb
require 'spec_helper'

describe DashboardController do

  before do
    @controller.should_receive(:authenticate_user!)
    @controller.stub(:update_last_request_stats)
    @controller.stub(:current_user).and_return(@current_user = User.new(user_type: User::READ_ONLY))
  end

  describe 'index' do
    describe 'html' do
      before { get :index }
      specify { response.should render_template(:index) }
    end
    describe 'js' do
      before { get :index, format: :js }
      specify { response.should render_template(:index) }
    end
  end
end