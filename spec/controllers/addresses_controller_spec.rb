require 'spec_helper'

describe AddressesController do

  before do
    @controller.should_receive :authenticate_user!
    @controller.stub :update_last_request_stats
    @controller.stub(:current_user).and_return(@current_user = User.new(user_type: User::READ_ONLY))
  end

  describe 'index' do
    describe 'default listing' do
      before { Address.should_receive(:ordered).and_return(@addresses = [Address.new]) }
      describe 'default page' do
        before do
          @addresses.should_receive(:page).with(nil).and_return(@addresses)
          get :index
        end
        specify { response.should render_template(:index) }
        specify { assigns[:addresses].should == @addresses }
      end
      describe 'page 2' do
        before do
          @addresses.should_receive(:page).with('2').and_return(@addresses)
          get :index, page: 2
        end
        specify { response.should render_template(:index) }
        specify { assigns[:addresses].should == @addresses }
      end
    end
  end

  describe 'search' do
    before do
      Address.should_receive(:search).with('xyz', '2').and_return(@addresses = [Address.new])
      get :search, query: 'xyz', page: 2
    end
    specify { response.should render_template(:index) }
    specify { assigns[:addresses].should == @addresses}
  end

  describe 'show' do
    before do
      Address.should_receive(:accessible_by).with(@current_user).and_return @address = FactoryGirl.build(:address)
      @address.should_receive(:find).with('12').and_return @address
      get :show, id: 12
    end
    specify { response.body.should == @address.to_json }
  end

  describe 'as read only user' do
    describe 'new' do
      before { get :new }
      specify { response.should redirect_to(root_path) }
    end
    describe 'create' do
      before { post :create }
      specify { response.should redirect_to(root_path) }
    end
    describe 'edit' do
      before { get :edit, id: 1 }
      specify { response.should redirect_to(root_path) }
    end
    describe 'update' do
      before { post :update, id: 1 }
      specify { response.should redirect_to(root_path) }
    end
    describe 'destroy' do
      before { post :destroy, id: 1 }
      specify { response.should redirect_to(root_path) }
    end
  end

  describe 'as client user' do
    before do
      @current_user.user_type = User::CLIENT
    end

    describe 'new' do
      describe 'without store ID' do
        before { get :new }
        specify { response.should render_template(:new) }
      end
      describe 'with store ID' do
        before do
          Store.should_receive(:find).with("45").and_return @store = double('Store', id: 45)
          get :new, store_id: 45
        end
        specify { response.should render_template(:new) }
        specify { assigns[:address].store_id.should == 45 }
        specify { assigns[:store].should == @store }
      end
      describe 'with distribution ID' do
        before do
          Distribution.should_receive(:find).with("45").and_return @distribution = a_pretend(:distribution, id: 45)
          get :new, distribution_id: 45
        end
        specify { response.should render_template(:new) }
        specify { assigns[:address].distribution_id.should == 45 }
        specify { assigns[:distribution].should == @distribution }
      end
    end
    describe 'edit' do
      before do
        Address.should_receive(:accessible_by).with(@current_user).and_return @address = Address.new
        @address.should_receive(:find).with('12').and_return @address
        get :edit, id: 12
      end
      specify { response.should render_template(:edit) }
      specify { assigns[:address].should == @address }
    end

    describe 'create' do
      before do
        AddressManager.should_receive(:new).with(@current_user).and_return @manager = double('AddressManager')
        @manager.should_receive(:create).with({'store_id' => "66"}).and_return @address = double('Address')
      end
      describe 'successfully' do
        before do
          @address.should_receive(:persisted?).and_return(true)
          post :create, address: {store_id: 66}
        end
        specify { response.should redirect_to(store_path(66)) }
        specify { flash[:notice].should == 'Address has been saved' }
      end
      describe 'unsuccessfully' do
        before do
          @address.should_receive(:persisted?).and_return(false)
          post :create, address: {store_id: 66}
        end
        specify { response.should render_template(:new) }
      end
    end

    describe 'update' do
      before do
        AddressManager.should_receive(:new).with(@current_user).and_return @manager = double('AddressManager')
        @manager.should_receive(:update).with('12', {'store_id' => "56"}).and_return @address = double('Address')
      end
      describe 'successfully' do
        before do
          @address.should_receive(:valid?).and_return(true)
          post :update, id: 12, address: {store_id: 56}
        end
        specify { response.should redirect_to(store_path(56)) }
        specify { flash[:notice].should == 'Changes have been saved' }
      end
      describe 'unsuccessfully' do
        before do
          @address.should_receive(:valid?).and_return(false)
          post :update, id: 12, address: {store_id: 56}
        end
        specify { response.should render_template(:edit) }
      end
    end
    describe 'destroy' do
      before do
        Address.should_receive(:accessible_by).with(@current_user).and_return @address = Address.new
        @address.should_receive(:find).with('12').and_return @address
        @address.should_receive(:destroy)
      end
      describe 'and redirect to address book' do
        before do
          post :destroy, id: 12, redirect: 'a'
        end
        specify { response.should redirect_to(addresses_path) }
        specify { flash[:notice].should == 'Address has been deleted.' }
      end
      describe 'and redirect to default' do
        before do
          post :destroy, id: 12
        end
        specify { response.should redirect_to(addresses_path) }
        specify { flash[:notice].should == 'Address has been deleted.' }
      end
      describe 'and redirect to store' do
        before do
          @address.should_receive(:store_id).and_return 5
          post :destroy, id: 12, redirect: 's'
        end
        specify { response.should redirect_to(store_path(5)) }
        specify { flash[:notice].should == 'Address has been deleted.' }
      end
    end
  end
end