# spec/controllers/documents_controller_spec.rb
require 'spec_helper'

describe ExportTemplatesController do
  before do
    @controller.should_receive(:authenticate_user!)
    @controller.stub(:update_last_request_stats)
    @controller.stub(:current_user).and_return(@current_user = User.new)
  end

  describe 'index' do
    before do
      ExportTemplate.should_receive(:all).and_return(@etemplates = double)
      get :index
    end
    specify { response.should render_template(:index) }
    specify { assigns[:templates].should == @etemplates }
  end

  describe 'new' do
    before { get :new }
    specify { response.should render_template(:new) }
    specify { assigns[:template].attributes.should == ExportTemplate.new.attributes }
  end

  describe 'create' do
    before do
      ExportTemplate.should_receive(:new).with('params').and_return @template = double
    end
    describe 'successfully' do
      before do
        @template.should_receive(:save).and_return true
        post :create, {export_template: 'params'}
      end
      specify { response.should redirect_to(export_templates_path) }
      specify { flash[:notice].should == 'Export template has been added' }
    end
    describe 'unsuccessfully' do
      before do
        @template.should_receive(:save).and_return false
        post :create, {export_template: 'params'}
      end
      specify { response.should render_template(:new) }
      specify { flash[:error].should == 'Template could not be saved.' }
    end
  end

  describe 'edit' do
    before do
      ExportTemplate.should_receive(:find).with('12').and_return @template = double
      get :edit, {id: 12}
    end
    specify { response.should render_template(:edit) }
    specify { assigns[:template].should == @template }
  end  

  describe 'update' do
    before { ExportTemplate.should_receive(:find).with('12').and_return @template = double }
    describe 'successfully' do
      before do
        @template.should_receive(:update_attributes).with('params').and_return true
        post :update, {id: 12, export_template: 'params'}
      end
      specify { response.should redirect_to(export_templates_path) }
      specify { flash[:notice].should == 'Template has been updated' }
    end
    describe 'unsuccessfully' do
      before do
        @template.should_receive(:update_attributes).with('params').and_return false
        post :update, {id: 12, export_template: 'params'}
      end
      specify { response.should render_template(:edit) }
      specify { flash[:error].should == 'Could not save the template' }
    end
  end

  describe 'destroy' do
    before do
      ExportTemplate.should_receive(:find).with('12').and_return @template = double(destroy: true)
      post :destroy, {id: 12}
    end
    specify { response.should redirect_to(export_templates_path) }
    specify { flash[:notice].should == 'Template deleted successfully' }
  end  
end