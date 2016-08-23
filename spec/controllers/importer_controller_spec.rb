require 'spec_helper'

describe ImporterController do

  before do
    @controller.should_receive :authenticate_user!
    @controller.stub :update_last_request_stats
    @controller.stub(:current_user).and_return(@current_user = FactoryGirl.build(:user))
  end

  describe 'template' do
    before do
      @csv = 'Name,Description,Reference,Code'
      ClientImporter.should_receive(:field_names_as_csv).and_return @csv
      get :template, id: 'client'
    end
    specify { response.should be_success }
    specify { response.body.should == @csv }
    specify { response.headers['Content-Type'].should == 'text/csv' }
    specify { response.headers['Content-Disposition'].should == 'attachment; filename="Pinpoint_Client_Template.csv"' }
  end

  describe 'index' do
    before { get :index }
    specify { response.should render_template(:index) }
    specify { assigns[:transport].attributes.should == Transport.new.attributes }
  end
end