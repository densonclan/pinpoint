# spec/controllers/documents_controller_spec.rb
require 'spec_helper'

describe DocumentsController do
  before do
    @controller.should_receive(:authenticate_user!)
    @controller.stub(:update_last_request_stats)
    @controller.stub(:current_user).and_return(@current_user = User.new)
  end

  describe 'index' do
    before do
      Document.should_receive(:accessible_by).with(@current_user).and_return @documents = [Document.new]
      @documents.should_receive(:page).with('2').and_return @documents
      get :index, page: 2
    end
    specify { response.should render_template(:index) }
    specify { assigns[:documents].should == @documents }
  end

  describe 'search' do
    before do
      Document.should_receive(:accessible_by).with(@current_user).and_return @documents = [Document.new]
      @documents.should_receive(:search).with('xyz').and_return @documents
      @documents.should_receive(:page).with('2').and_return @documents
      get :search, query: 'xyz', page: '2'
    end
    specify { response.should render_template(:search) }
    specify { assigns[:documents].should == @documents }
  end

  describe 'as read only user' do
    before { @current_user.user_type = User::READ_ONLY }
    describe 'new' do
      before { get :new }
      specify { response.should redirect_to(root_path) }
    end
    describe 'create' do
      before { post :create }
      specify { response.should redirect_to(root_path) }
    end
    describe 'edit' do
      before { get :edit, id: 4 }
      specify { response.should redirect_to(root_path) }
    end
    describe 'update' do
      before { post :update, id: 4 }
      specify { response.should redirect_to(root_path) }
    end
    describe 'destroy' do
      before { post :destroy, id: 4 }
      specify { response.should redirect_to(root_path) }
    end
  end
  describe 'as client user' do
    before { @current_user.user_type = User::CLIENT }
    describe 'new' do
      before { @document = Document.new }
      describe 'without store' do
        before do
          Document.should_receive(:new).with({store_id: nil}).and_return @document
          get :new
        end
        specify { response.should render_template(:new) }
        specify { assigns[:document].should == @document }
      end
      describe 'with store' do
        before do
          Document.should_receive(:new).with({store_id: '12'}).and_return @document
          get :new, store_id: '12'
        end
        specify { response.should render_template(:new) }
        specify { assigns[:document].should == @document }
      end
    end

    describe 'create' do
      before do
        Document.should_receive(:new_with_user).with('params', @current_user).and_return @document = a_pretend(:document, store_id: 14)
      end
      describe 'successfully' do
        before do
          @document.should_receive(:save).and_return true
          post :create, document: 'params'
        end
        specify { response.should redirect_to(documents_store_path(14)) }
        specify { flash[:notice].should == 'Document saved successfully' }
      end
      describe 'unsuccessfully' do
        before do
          @document.should_receive(:save).and_return false
          post :create, document: 'params'
        end
        specify { response.should render_template(:new) }
        specify { flash[:error].should == 'Error saving document' }
        specify { assigns[:document].should == @document }
      end
    end

    describe 'actions requiring a document' do
      before do
        Document.should_receive(:accessible_by).with(@current_user).and_return @document = a_pretend(:document, store_id: 14)
        @document.should_receive(:find).with('12').and_return @document
      end

      describe 'edit' do
        before { get :edit, id: '12' }
        specify { response.should render_template(:edit) }
        specify { assigns[:document].should == @document }
      end

      describe 'destroy' do
        before { post :destroy, id: '12' }
        specify { response.should redirect_to(documents_store_path(14)) }
        specify { flash[:notice].should == 'Document deleted successfully' }
      end

      describe 'update' do
        describe 'successfully' do
          before do
            @document.should_receive(:update_attributes).with('params').and_return true
            post :update, id: 12, document: 'params'
          end
          specify { response.should redirect_to(documents_store_path(14)) }
          specify { flash[:notice].should == 'Document updated successfully' }
        end
        describe 'unsuccessfully' do
          before do
            @document.should_receive(:update_attributes).with('params').and_return false
            post :update, id: 12, document: 'params'
          end
          specify { response.should render_template(:edit) }
          specify { flash[:error].should == 'Error saving document' }
          specify { assigns[:document].should == @document }
        end
      end
    end
  end
end