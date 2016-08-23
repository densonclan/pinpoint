# spec/controllers/business_managers_controller_spec.rb
require 'spec_helper'

describe BusinessManagersController do

  before do
    @controller.should_receive(:authenticate_user!)
    @controller.should_receive(:require_internal)
    @controller.stub(:current_user).and_return(@current_user = User.new)
  end

  describe "index" do
    before do
      BusinessManager.should_receive(:ordered).and_return @bms = double
    end

    describe "default page" do
      before do
        @bms.should_receive(:page).with(nil).and_return(@bms)
        get :index
      end
      specify { response.should render_template(:index) }
      specify { assigns(:managers).should == @bms }
    end

    describe "page 2" do
      before do
        @bms.should_receive(:page).with('2').and_return(@bms)
        get :index, page: 2
      end
      specify { response.should render_template(:index) }
      specify { assigns(:managers).should == @bms }
    end
  end

  describe 'search' do

    before do
      BusinessManager.should_receive(:for_listing).and_return @bms = double
      @bms.should_receive(:ordered).and_return @bms
      @bms.should_receive(:search).with('xyz').and_return @bms
      @bms.should_receive(:page).with('2').and_return @bms
      get :search, {query: 'xyz', page: 2}
    end
    specify { response.should render_template(:index) }
    specify { assigns[:managers].should == @bms }
  end

  describe "new" do
    before do
      get :new
    end
    specify { response.should render_template(:new) }
    specify { assigns[:manager].attributes.should == BusinessManager.new.attributes }
  end

  describe "edit" do
    before do
      BusinessManager.should_receive(:find).with('12').and_return(@bm = BusinessManager.new)
      get :edit, id: 12
    end
    specify { response.should render_template(:edit) }
    specify { assigns[:manager].should == @bm }
  end

  describe 'create' do
    before { BusinessManager.should_receive(:new).with(@params = 'xyz').and_return(@bm = double) }
    describe 'successfully' do
      before do
        @bm.should_receive(:save).and_return(true)
        post :create, {business_manager: @params}
      end
      specify { response.should redirect_to(business_managers_path) }
      specify { flash[:notice].should == 'New manager has been added.' }
    end
    describe 'unsuccessfully' do
      before do
        @bm.should_receive(:save).and_return(false)
        post :create, {business_manager: @params}
      end
      specify { response.should render_template(:new) }
      specify { flash[:error].should == "Could not add new Manager." }
    end
  end

  describe 'update' do
    before { BusinessManager.should_receive(:find).with('12').and_return(@bm = double) }
    describe 'successfully' do
      before do
        @bm.should_receive(:update_attributes).with('params').and_return(true)
        post :update, id: 12, business_manager: 'params'
      end
      specify { response.should redirect_to(business_managers_path) }
      specify { flash[:notice].should == 'Business Manager saved successfully' }
    end
    describe 'unsuccessfully' do
      before do
        @bm.should_receive(:update_attributes).with('params').and_return(false)
        post :update, id: 12, business_manager: 'params'
      end
      specify { response.should render_template(:edit) }
      specify { flash[:error].should == "Error saving this business manager" }
    end
  end

  describe 'destroy' do
    before do
      BusinessManager.should_receive(:find).with('12').and_return(@bm = double)
      @bm.should_receive(:destroy)
      post :destroy, id: 12
    end
    specify { response.should redirect_to(business_managers_path) }
    specify { flash[:notice].should == 'Business Manager deleted successfully' }
  end
end