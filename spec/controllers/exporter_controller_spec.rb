require 'spec_helper'

describe ExporterController do
  before do
    @controller.should_receive(:authenticate_user!)
    @controller.stub(:update_last_request_stats)
    @controller.stub(:current_user).and_return(@current_user = User.new)
  end

  describe 'index' do
    before { get :index }
    specify { response.should render_template(:index) }
  end

  describe 'processor' do
    before do
      DistributionExporter.should_receive(:new).with(@current_user, {'blah' => 'yadda'}).and_return double('DistributionExporter', export: 'result!', file_name: 'export.xls')
      post :processor, {blah: 'yadda'}
    end
    specify { response.should be_success }
    specify { response.body.should == 'result!' }
    specify { response.headers['Content-Type'].should == 'application/vnd.ms-excel' }
    specify { response.headers['Content-Disposition'].should == 'attachment; filename="export.xls"' }
  end
end