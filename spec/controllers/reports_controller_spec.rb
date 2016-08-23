require 'spec_helper'

describe ReportsController do

  before do
    @controller.should_receive :authenticate_user!
    @controller.stub :update_last_request_stats
    @controller.stub(:current_user).and_return(@current_user = User.new(user_type: User::READ_ONLY))
  end

  describe 'index' do
    describe 'in HTML' do
      before { get :index }
      specify { response.should render_template(:index) }
    end
    describe 'in JS' do
      before { get :index, format: :js }
      specify { response.should render_template(:index) }
    end
  end

  describe 'activity' do
    before do
      @resources = double
      @resources.should_receive(:reverse_update_order).and_return @resources
      @resources.should_receive(:page).with('2').and_return @resources
    end
    describe 'orders' do
      before do
        Order.should_receive(:for_activity_list).and_return @resources
        get :activity, type: 'orders', page: 2
      end
      specify { response.should render_template(:activity) }
      specify { assigns[:resources].should == @resources }
    end
    describe 'stores' do
      before do
        Store.should_receive(:for_activity_list).and_return @resources
        get :activity, type: 'stores', page: 2
      end
      specify { response.should render_template(:activity) }
      specify { assigns[:resources].should == @resources }
    end
  end

  describe 'clients' do
    before do
      @controller.should_receive :require_internal
      Client.should_receive(:with_periods).and_return @clients = double
      get :clients
    end
    specify { response.should render_template(:clients) }
    specify { assigns[:clients].should == @clients }
  end

  context '#quantites' do
    let(:reporter) { double('OrderQuantityReporter') }
    before { OrderQuantityReporter.should_receive(:new).with(@current_user, params).and_return reporter }
    describe 'html format' do
      let(:params) { {'param' => 'value', "controller"=>"reports", "action"=>"quantities"} }
      before { get :quantities, {param: 'value'} }
      specify { response.should render_template(:quantities) }
      specify { assigns[:reporter].should == reporter }
    end

    describe 'xls format' do
      let(:exporter) { double('OrderQuantityReportExporter', export: 'data!', file_name: 'file.xls') }
      let(:params) { {'param' => 'value', "format"=>"xls", "controller"=>"reports", "action"=>"quantities"} }
      before do
        OrderQuantityReportExporter.should_receive(:new).with(reporter).and_return exporter
        get :quantities, {param: 'value', format: :xls}
      end
      specify { response.body.should == 'data!' }
      specify { response.headers['Content-Type'].should == 'application/vnd.ms-excel' }
      specify { response.headers['Content-Disposition'].should == 'attachment; filename="file.xls"' }
    end
  end
end