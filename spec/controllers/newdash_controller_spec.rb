require 'spec_helper'

describe NewdashController do

  before do
    @controller.should_receive(:authenticate_user!)
    @controller.stub(:update_last_request_stats)
    @controller.stub(:current_user).and_return(@current_user = FactoryGirl.create(:user, client_id: 1))
  end

  describe "GET 'index'" do
    it "returns http success" do
      get :index
      response.should be_success
    end
  end

end
