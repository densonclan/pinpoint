# spec/controllers/stores_controller_spec.rb
require 'spec_helper'

describe StoresController do

  before do
    @controller.should_receive(:authenticate_user!)
    @controller.stub(:update_last_request_stats)
    @controller.stub(:current_user).and_return(@current_user = FactoryGirl.create(:user, client_id: 1))
  end

  describe 'index' do
    before { Store.should_receive(:list_for).with(@current_user).and_return(@stores = [Store.new]) }
    describe 'default order' do
      before do
        @stores.should_receive(:order_by).with(nil, nil).and_return @stores
        @stores.should_receive(:page).with(nil).and_return @stores
        get :index
      end
      specify { response.should render_template(:index) }
      specify { assigns[:stores].should == @stores }
    end
    describe 'specify order' do
      before do
        @stores.should_receive(:order_by).with('name', 'desc').and_return @stores
        @stores.should_receive(:page).with(nil).and_return @stores
        get :index, sort: 'name', direction: 'desc'
      end
      specify { response.should render_template(:index) }
      specify { assigns[:stores].should == @stores }
    end
    describe 'specify order and page' do
      before do
        @stores.should_receive(:order_by).with('name', 'desc').and_return @stores
        @stores.should_receive(:page).with('3').and_return @stores
        get :index, sort: 'name', direction: 'desc', page: 3
      end
      specify { response.should render_template(:index) }
      specify { assigns[:stores].should == @stores }
    end
  end

  describe 'advanced' do
    before do
      Store.should_receive(:list_for).with(@current_user).and_return(@stores = [Store.new])
      @stores.should_receive(:order_by).with(nil, nil).and_return @stores
      @stores.should_receive(:filter).with('x', 'y', 'z').and_return @stores
      @stores.should_receive(:page).with('2').and_return @stores
      get :advanced, client: 'x', business_manager: 'y', county: 'z', page: 2
    end
    specify { response.should render_template(:index) }
    specify { assigns[:stores].should == @stores }
  end  

  describe 'requiring a store' do
    before do
      Store.should_receive(:accessible_by).with(@current_user).and_return(@store = Store.new)
      @store.should_receive(:find).with('12').and_return(@store)
    end      

    describe 'map' do
      before { get :map, id: 12 }
      specify { response.should render_template(:map) }
      specify { assigns[:store].should == @store }
    end
    describe 'show' do
      describe 'default format' do
        before { get :show, id: 12 }
        specify { response.should render_template(:show) }
        specify { assigns[:store].should == @store }
      end
      describe 'pdf format' do
        before { get :show, id: 12, format: :pdf }
        specify { response.should render_template(:show) }
        specify { assigns[:store].should == @store }
      end
    end
    describe 'documents' do
      before do
        @store.should_receive(:documents).and_return(@documents = [Document.new])
        @documents.should_receive(:ordered).and_return @documents
        @documents.should_receive(:page).with('2').and_return @documents
        get :documents, id: 12, page: 2
      end
      specify { response.should render_template(:documents) }
      specify { assigns[:store].should == @store }
      specify { assigns[:documents].should == @documents }
    end
    describe 'orders' do
      before do
        @store.should_receive(:orders).and_return(@orders = double)
        @orders.should_receive(:for_listing).and_return @orders
        @orders.should_receive(:order).and_return @orders
        @orders.should_receive(:page).with('2').and_return @orders
        get :orders, id: 12, page: 2
      end
      specify { response.should render_template(:orders) }
      specify { assigns[:store].should == @store }
      specify { assigns[:orders].should == @orders }
    end
    describe 'notes' do
      before do
        @store.should_receive(:comments).and_return(@comments = [Comment.new])
        @comments.should_receive(:ordered).and_return @comments
        @comments.should_receive(:page).with('2').and_return @comments
        get :notes, id: 12, page: 2
      end
      specify { response.should render_template(:notes) }
      specify { assigns[:store].should == @store }
      specify { assigns[:comments].should == @comments }
    end
    describe 'other' do
      before do
        @store.should_receive(:find_others).and_return @stores = [Store.new, Store.new]
        @stores.should_receive(:for_listing).and_return @stores
      end
      describe 'default' do
        before do
          @stores.should_receive(:order_by).with(nil, nil).and_return @stores
          @stores.should_receive(:page).with(nil).and_return @stores
          get :other, id: 12
        end
        specify { response.should render_template(:other) }
        specify { assigns[:store].should == @store }
        specify { assigns[:stores].should == @stores }
      end
      describe 'ordered' do
        before do
          @stores.should_receive(:order_by).with('name', 'asc').and_return @stores
          @stores.should_receive(:page).with(nil).and_return @stores
          get :other, id: 12, direction: 'asc', sort: 'name'
        end
        specify { response.should render_template(:other) }
        specify { assigns[:store].should == @store }
        specify { assigns[:stores].should == @stores }
      end
      describe 'ordered page 2' do
        before do
          @stores.should_receive(:order_by).with('name', 'asc').and_return @stores
          @stores.should_receive(:page).with('2').and_return @stores
          get :other, id: 12, direction: 'asc', sort: 'name', page: 2
        end
        specify { response.should render_template(:other) }
        specify { assigns[:store].should == @store }
        specify { assigns[:stores].should == @stores }
      end
    end
  end

  describe 'search' do
    before do
      store1 = FactoryGirl.create(:store, description: 'abc', client_id: @current_user.client_id)
      store2 = FactoryGirl.create(:store, description: 'abc', client_id: @current_user.client_id)
      @stores = [store1, store2]
      get :search, query: 'abc', page: 1
    end
    specify { response.should render_template(:search) }
    specify { assigns[:stores].count.should == 2 }
  end

  describe 'suggest' do
    before do
      Store.should_receive(:accessible_by).with(@current_user).and_return @stores = [double(account_number: 'XYZ'), double(account_number: 'ABC')]
      @stores.should_receive(:matching).with('abc').and_return @stores
      @stores.should_receive(:limit).with(5).and_return @stores
      get :suggest, term: 'abc', format: :json
    end
    specify { response.body.should == '["XYZ","ABC"]' }
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
      before { get :edit, id: 12 }
      specify { response.should redirect_to(root_path) }
    end
    describe 'update' do
      before { post :update, id: 12 }
      specify { response.should redirect_to(root_path) }
    end
    describe 'destroy' do
      before { post :destroy, id: 12 }
      specify { response.should redirect_to(root_path) }
    end
  end

  describe 'as client' do
    before { @current_user.user_type = User::CLIENT }
    describe 'new' do
      before do
        @store = Store.new
        Store.should_receive(:new).and_return @store
        get :new
      end
      specify { response.should render_template(:new) }
      specify { assigns[:store].should == @store }
    end

    describe 'create' do
      before do
        Store.should_receive(:new_with_user).with('attrs', @current_user).and_return(@store = Store.new)
      end
      describe 'successfully' do
        before do
          @store.should_receive(:lock!).with(@current_user)
          @store.should_receive(:save).and_return(true)
          @store.stub(:id).and_return(45)
          @store.stub(:new_record?).and_return(false)
          post :create, store: 'attrs'
        end
        specify { response.should redirect_to(new_address_path(store_id: 45)) }
        specify { flash[:notice].should == "Store has been added." }
      end
      describe 'unsuccessfully' do
        before do
          @store.should_receive(:save).and_return(false)
          post :create, store: 'attrs'
        end
        specify { response.should render_template(:new) }
        specify { flash[:error].should == "Could not save the store." }
      end
    end

    describe 'edit' do
      before do
        Store.should_receive(:accessible_by).with(@current_user).and_return @store = Store.new
        @store.should_receive(:find).with('12').and_return @store
        get :edit, id: 12
      end
      specify { response.should render_template(:edit) }
      specify { assigns[:store].should == @store }
    end

    describe 'update' do
      before do
        Store.should_receive(:accessible_by).with(@current_user).and_return @store = Store.new
        @store.should_receive(:find).with('12').and_return @store
        @store.should_receive(:set_attributes_with_user).with('params', @current_user)
      end
      describe 'successfully' do
        before do
          @store.should_receive(:save).and_return true
          @store.stub(:new_record?).and_return(false)
          @store.stub(:id).and_return(12)
          post :update, id: 12, store: 'params'
        end
        specify { response.should redirect_to(store_path(12)) }
        specify { flash[:notice].should == "Changes have been saved" }
      end
      describe 'unsuccessfully' do
        before do
          @store.should_receive(:save).and_return false
          post :update, id: 12, store: 'params'
        end
        specify { flash[:error].should == 'Could not save changes' }
        specify { response.should render_template(:edit) }
        specify { assigns[:store].should == @store }
      end
    end

    describe 'destroy' do
      before do
        Store.should_receive(:accessible_by).with(@current_user).and_return @store = Store.new
        @store.should_receive(:find).with('12').and_return @store
      end
      describe 'successfully' do
        before do
          @store.should_receive(:destroy).and_return true
          post :destroy, id: 12
        end
        specify { response.should redirect_to(stores_path) }
        specify { flash[:notice].should == "Store has been deleted." }
      end
      describe 'unsuccessfully' do
        before do
          @store.should_receive(:destroy).and_return false
          post :destroy, id: 12
        end
        specify { response.should render_template(:edit) }
        specify { assigns[:store].should == @store }
      end
    end
  end 
end