# spec/controllers/clients_controller_spec.rb
require 'spec_helper'

describe ClientsController do
  before do
    @controller.should_receive(:authenticate_user!)
    @controller.should_receive(:require_internal)
    @controller.stub(:update_last_request_stats)
    @controller.stub(:current_user).and_return(@current_user = User.new)
  end

  describe 'index' do
    before do
      Client.should_receive(:ordered).and_return @clients = [Client.new]
      @clients.should_receive(:page).with('2').and_return @clients
      get :index, page: 2
    end
    specify { response.should render_template(:index) }
    specify { assigns[:clients].should == @clients }
  end

  describe 'new' do
    before { get :new }
    specify { response.should render_template(:new) }
    specify { assigns[:client].attributes.should == Client.new.attributes }
  end

  describe 'create' do
    before do
      @client = Client.new
      Client.should_receive(:new).with('params').and_return @client
    end
    describe 'successfully' do
      before do
        @client.should_receive(:save).and_return(true)
        post :create, client: 'params'
      end
      specify { response.should redirect_to(clients_path) }
      specify { flash[:notice].should == 'Client saved successfully' }
    end
    describe 'unsuccessfully' do
      before do
        @client.should_receive(:save).and_return(false)
        post :create, client: 'params'
      end
      specify { response.should render_template(:new) }
      specify { flash[:error].should == 'Error saving client' }
    end
  end

  describe 'edit' do
    before do
      Client.should_receive(:find).with('12').and_return @client = Client.new
      get :edit, id: 12
    end
    specify { response.should render_template(:edit) }
    specify { assigns[:client].should == @client }
  end

  describe 'update' do
    before { Client.should_receive(:find).with('12').and_return @client = Client.new }
    describe 'successfully' do
      before do
        @client.should_receive(:update_attributes).with('params').and_return true
        post :update, id: 12, client: 'params'
      end
      specify { response.should redirect_to(clients_path) }
      specify { flash[:notice].should == 'Client saved successfully' }
    end
    describe 'unsuccessfully' do
      before do
        @client.should_receive(:update_attributes).with('params').and_return false
        post :update, id: 12, client: 'params'
      end
      specify { response.should render_template(:edit) }
      specify { flash[:error].should == 'Error saving client' }
    end
  end

  describe 'destroy' do
    before do
      Client.should_receive(:find).with('12').and_return @client = Client.new
      @client.should_receive(:destroy)
      post :destroy, id: 12
    end
      specify { response.should redirect_to(clients_path) }
      specify { flash[:notice].should == 'Client deleted successfully' }
  end
end