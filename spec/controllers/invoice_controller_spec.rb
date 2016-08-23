require 'spec_helper'

describe InvoiceController do
  before do
    @controller.should_receive(:authenticate_user!)
    @controller.stub(:update_last_request_stats)
    @controller.stub(:current_user).and_return(@current_user = FactoryGirl.build(:user))
  end

  describe 'index' do
    before { get :index }
    specify { response.should render_template(:index) }
  end

  describe 'processor' do
    before do
      InvoiceExporter.should_receive(:new).with(@current_user, {'blah' => 'yadda'}).and_return double('InvoiceExporter', export: 'result!', file_name: 'export.xls')
      post :processor, {blah: 'yadda'}
    end
    specify { response.should be_success }
    specify { response.body.should == 'result!' }
    specify { response.headers['Content-Type'].should == 'application/vnd.ms-excel' }
    specify { response.headers['Content-Disposition'].should == 'attachment; filename="export.xls"' }
  end
end