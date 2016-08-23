# spec/controllers/distributors_controller_spec.rb
require 'spec_helper'

describe DistributorsController do
  before do
    @controller.should_receive(:authenticate_user!)
    @controller.should_receive(:require_internal)
    @controller.stub(:update_last_request_stats)
    @controller.stub(:current_user).and_return(@current_user = User.new)
  end

  describe 'index' do
    before do
      Distributor.should_receive(:ordered).and_return @distributors = [Distributor.new]
      get :index
    end
    specify { response.should render_template(:index) }
    specify { assigns[:distributors].should == @distributors }
  end

  describe 'new' do
    before { get :new }
    specify { response.should render_template(:new) }
    specify { assigns[:distributor].attributes.should == Distributor.new.attributes }
  end

  describe 'create' do
    before do
      @distributor = Distributor.new
      Distributor.should_receive(:new).with('params').and_return @distributor
    end
    describe 'successfully' do
      before do
        @distributor.should_receive(:save).and_return(true)
        post :create, distributor: 'params'
      end
      specify { response.should redirect_to(distributors_path) }
      specify { flash[:notice].should == 'Distributor saved successfully' }
    end
    describe 'unsuccessfully' do
      before do
        @distributor.should_receive(:save).and_return(false)
        post :create, distributor: 'params'
      end
      specify { response.should render_template(:new) }
      specify { flash[:error].should == 'Error saving distributor' }
    end
  end

  describe 'edit' do
    before do
      Distributor.should_receive(:find).with('12').and_return @distributor = Distributor.new
      get :edit, id: 12
    end
    specify { response.should render_template(:edit) }
    specify { assigns[:distributor].should == @distributor }
  end

  describe 'update' do
    before { Distributor.should_receive(:find).with('12').and_return @distributor = Distributor.new }
    describe 'successfully' do
      before do
        @distributor.should_receive(:update_attributes).with('params').and_return true
        post :update, id: 12, distributor: 'params'
      end
      specify { response.should redirect_to(distributors_path) }
      specify { flash[:notice].should == 'Distributor saved successfully' }
    end
    describe 'unsuccessfully' do
      before do
        @distributor.should_receive(:update_attributes).with('params').and_return false
        post :update, id: 12, distributor: 'params'
      end
      specify { response.should render_template(:edit) }
      specify { flash[:error].should == 'Error saving distributor' }
    end
  end

  describe 'destroy' do
    before do
      Distributor.should_receive(:find).with('12').and_return @distributor = Distributor.new
      @distributor.should_receive(:destroy)
      post :destroy, id: 12
    end
      specify { response.should redirect_to(distributors_path) }
      specify { flash[:notice].should == 'Distributor deleted successfully' }
  end
end