require 'spec_helper'

describe TransportsController do

  before do
    @controller.should_receive :authenticate_user!
    @controller.stub :update_last_request_stats
    @controller.stub(:current_user).and_return(@current_user = FactoryGirl.create(:user, email: 'steve@microsoft.com'))
  end

  describe 'create' do
    before { Transport.should_receive(:new_with_user).with('params', @current_user).and_return(@transport = double) }
    describe 'successfully' do
      before do
        @transport.should_receive(:save).and_return true
        post :create, {transport: 'params'}
      end
      specify { response.should redirect_to(importer_index_path) }
      specify { flash[:notice].should == "Import created successfully. Execution will begin within the next 10 minutes and the results will be emailed to steve@microsoft.com" }
    end

    describe 'unsuccessfully' do
      before do
        @transport.should_receive(:save).and_return false
        post :create, {transport: 'params'}
      end
      specify { response.should render_template('importer/index') }
      specify { flash[:error].should == "You have not selected a file or chosen the correct section." }
      specify { assigns[:transport].should == @transport }
    end
  end
end