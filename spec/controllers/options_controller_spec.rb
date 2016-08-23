# spec/controllers/options_controller_spec.rb
require 'spec_helper'

describe OptionsController do
  before do
    @controller.should_receive(:authenticate_user!)
    @controller.should_receive(:require_internal)
    @controller.stub(:update_last_request_stats)
    @controller.stub(:current_user).and_return(@current_user = User.new)
  end

  describe 'index' do
    before do
      Option.should_receive(:ordered).and_return @options = [Option.new]
      get :index
    end
    specify { response.should render_template(:index) }
    specify { assigns[:options].should == @options }
  end

  describe 'new' do
    before { get :new }
    specify { response.should render_template(:new) }
    specify { assigns[:option].attributes.should == Option.new.attributes }
  end

  describe 'create' do
    before do
      @option = Option.new
      Option.should_receive(:new).with('params').and_return @option
    end
    describe 'successfully' do
      before do
        @option.should_receive(:save).and_return(true)
        post :create, option: 'params'
      end
      specify { response.should redirect_to(options_path) }
      specify { flash[:notice].should == 'Option saved successfully' }
    end
    describe 'unsuccessfully' do
      before do
        @option.should_receive(:save).and_return(false)
        post :create, option: 'params'
      end
      specify { response.should render_template(:new) }
      specify { flash[:error].should == 'Error saving option' }
    end
  end

  describe 'edit' do
    before do
      Option.should_receive(:with_all_values).and_return @option = Option.new
      @option.should_receive(:find).with('12').and_return @option
      get :edit, id: 12
    end
    specify { response.should render_template(:edit) }
    specify { assigns[:option].should == @option }
  end

  describe 'update' do
    before do
      Option.should_receive(:with_all_values).and_return @option = Option.new
      @option.should_receive(:find).with('12').and_return @option
    end
    describe 'successfully' do
      before do
        @option.should_receive(:update_attributes).with('params').and_return true
        post :update, id: 12, option: 'params'
      end
      specify { response.should redirect_to(options_path) }
      specify { flash[:notice].should == 'Option saved successfully' }
    end
    describe 'unsuccessfully' do
      before do
        @option.should_receive(:update_attributes).with('params').and_return false
        post :update, id: 12, option: 'params'
      end
      specify { response.should render_template(:edit) }
      specify { flash[:error].should == 'Error saving option' }
    end
  end

  describe 'destroy' do
    before do
      Option.should_receive(:find).with('12').and_return @option = Option.new
      @option.should_receive(:destroy)
      post :destroy, id: 12
    end
      specify { response.should redirect_to(options_path) }
      specify { flash[:notice].should == 'Option deleted successfully' }
  end
end