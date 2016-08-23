# spec/controllers/pages_controller_spec.rb
require 'spec_helper'

describe PagesController do
  before do
    @controller.should_receive(:authenticate_user!)
    @controller.should_receive(:require_internal)
    @controller.stub(:update_last_request_stats)
    @controller.stub(:current_user).and_return(@current_user = User.new)
  end

  describe 'index' do
    before do
      Page.should_receive(:ordered).and_return @pages = [Page.new]
      get :index
    end
    specify { response.should render_template(:index) }
    specify { assigns[:pages].should == @pages }
  end

  describe 'new' do
    before { get :new }
    specify { response.should render_template(:new) }
    specify { assigns[:page].attributes.should == Page.new.attributes }
  end

  describe 'create' do
    before do
      @page = Page.new
      Page.should_receive(:new).with('params').and_return @page
    end
    describe 'successfully' do
      before do
        @page.should_receive(:save).and_return(true)
        post :create, page: 'params'
      end
      specify { response.should redirect_to(pages_path) }
      specify { flash[:notice].should == 'Page saved successfully' }
    end
    describe 'unsuccessfully' do
      before do
        @page.should_receive(:save).and_return(false)
        post :create, page: 'params'
      end
      specify { response.should render_template(:new) }
      specify { flash[:error].should == 'Error saving page' }
    end
  end

  describe 'edit' do
    before do
      Page.should_receive(:find).with('12').and_return @page = Page.new
      get :edit, id: 12
    end
    specify { response.should render_template(:edit) }
    specify { assigns[:page].should == @page }
  end

  describe 'update' do
    before { Page.should_receive(:find).with('12').and_return @page = Page.new }
    describe 'successfully' do
      before do
        @page.should_receive(:update_attributes).with('params').and_return true
        post :update, id: 12, page: 'params'
      end
      specify { response.should redirect_to(pages_path) }
      specify { flash[:notice].should == 'Page saved successfully' }
    end
    describe 'unsuccessfully' do
      before do
        @page.should_receive(:update_attributes).with('params').and_return false
        post :update, id: 12, page: 'params'
      end
      specify { response.should render_template(:edit) }
      specify { flash[:error].should == 'Error saving page' }
    end
  end

  describe 'destroy' do
    before do
      Page.should_receive(:find).with('12').and_return @page = Page.new
      @page.should_receive(:destroy)
      post :destroy, id: 12
    end
      specify { response.should redirect_to(pages_path) }
      specify { flash[:notice].should == 'Page deleted successfully' }
  end
end