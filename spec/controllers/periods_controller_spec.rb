# spec/controllers/periods_controller_spec.rb
require 'spec_helper'

describe PeriodsController do

  before do
    @controller.should_receive(:authenticate_user!)
    @controller.stub(:update_last_request_stats)
    @controller.stub(:current_user).and_return(@current_user = User.new)
  end

  describe 'index' do
    before do
      Client.should_receive(:ordered).and_return @clients = [Client.new]
      Period.should_receive(:ordered).and_return @periods = [Period.new]
      get :index
    end
    specify { response.should render_template(:index) }
    specify { assigns[:clients].should == @clients }
    specify { assigns[:periods].should == @periods }
  end

  describe 'review' do
    before { Period.should_receive(:find).with('12').and_return @period = double(client_id: 6) }
    describe 'current period' do
      before do
        @period.should_receive(:current).and_return true
        @period.should_receive(:next_period).and_return @next = double('Period')
        @period.should_receive(:orders).exactly(3).times.and_return @orders = double('Orders')
        @orders.should_receive(:for_review_list).and_return @orders
        @orders.should_receive(:ordered).and_return @orders
        @orders.should_receive(:select).and_return @orders
        @orders.should_receive(:for_store_without_logo).and_return @orders
        @orders.should_receive(:page).with(1).and_return @orders
        Store.should_receive(:for_client).with(6).and_return @stores = double('Stores')
        @stores.should_receive(:without_orders_in_periods).with(@period, @next).and_return @stores
        @stores.should_receive(:ordered).and_return @stores
        @stores.should_receive(:page).with(1).and_return @stores
        get :review, id: 12
      end
      specify { response.should render_template(:review) }
      specify { assigns[:period].should == @period }
      specify { assigns[:period_new].should == @next }
      specify { assigns[:orders].should == @orders }
      specify { assigns[:non_order_stores].should == @stores }
    end
    describe 'non-current period' do
      before do
        @period.should_receive(:current).and_return false
        get :review, id: 12
      end
      specify { response.should redirect_to(periods_path) }
      specify { flash[:error].should == 'Cannot review non-current periods.' }
    end
  end

  describe 'compile' do
    let(:next_period) { a_pretend(:period, id: 13) }
    let(:period) { double('Period', next_period: next_period) }
    let(:period_compiler) { double('PeriodCompiler', perform: period) }
    before do
      PeriodCompiler.should_receive(:new).with(@current_user.id, '12').and_return period_compiler
      post :compile, id: 12
    end
    specify { response.should redirect_to(periods_path) }
    specify { flash[:notice].should == "Period has been queued for compilation and will be completed within a few seconds" }
  end

  describe 'new' do
    before { get :new }
    specify { response.should render_template(:new) }
    specify { assigns[:period].attributes.should == Period.new.attributes }
  end

  describe 'create' do
    before do
      @period = Period.new
      Period.should_receive(:new).with('params').and_return @period
    end
    describe 'successfully' do
      before do
        @period.should_receive(:save).and_return(true)
        post :create, period: 'params'
      end
      specify { response.should redirect_to(periods_path) }
      specify { flash[:notice].should == 'Period saved successfully' }
    end
    describe 'unsuccessfully' do
      before do
        @period.should_receive(:save).and_return(false)
        post :create, period: 'params'
      end
      specify { response.should render_template(:new) }
      specify { flash[:error].should == 'Error saving period' }
    end
  end

  describe 'edit' do
    before do
      Period.should_receive(:find).with('12').and_return @period = Period.new
      get :edit, id: 12
    end
    specify { response.should render_template(:edit) }
    specify { assigns[:period].should == @period }
  end

  describe 'update' do
    before { Period.should_receive(:find).with('12').and_return @period = Period.new }
    describe 'successfully' do
      before do
        @period.should_receive(:update_attributes).with('params').and_return true
        post :update, id: 12, period: 'params'
      end
      specify { response.should redirect_to(periods_path) }
      specify { flash[:notice].should == 'Period saved successfully' }
    end
    describe 'unsuccessfully' do
      before do
        @period.should_receive(:update_attributes).with('params').and_return false
        post :update, id: 12, period: 'params'
      end
      specify { response.should render_template(:edit) }
      specify { flash[:error].should == 'Error saving period' }
    end
  end

  describe 'destroy' do
    let(:period) { FactoryGirl.create :period }

    before { post :destroy, id: period.id }

    specify { response.should redirect_to(periods_path) }
    specify { flash[:notice].should == 'Period deleted successfully' }

    describe 'period' do
      subject { Period.where id: period.id }
      it { should be_blank }
    end
  end
end
