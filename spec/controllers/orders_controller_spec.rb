# spec/controllers/orders_controller_spec.rb
require 'spec_helper'

describe OrdersController do

  before do
    @controller.should_receive(:authenticate_user!)
    @controller.stub(:update_last_request_stats)
    @controller.stub(:current_user).and_return(@current_user = User.new(user_type: User::READ_ONLY))
    Distributor.stub(:count).and_return 4
  end

  describe 'as read only user' do

    %w(update_status new edit copy).each do |a|
      describe a do
        before { get a.to_sym, id: 12 }
        specify { response.should redirect_to(root_path) }
      end
    end

    %w(update create destroy update_orders).each do |a|
      describe a do
        before { post a.to_sym, id: 12 }
        specify { response.should redirect_to(root_path) }
      end
    end
  end

  describe 'as client user' do
    before do
      @current_user.user_type = User::CLIENT
    end

    describe "update_status" do
      before do
        Option.should_receive(:accessible_by).with(@current_user).and_return @option = double(id: 5)
        Order.should_receive(:accessible_by).with(@current_user).and_return @orders = [Order.new]
        @orders.should_receive(:for_listing).and_return @orders
        @orders.should_receive(:for_current_period).and_return @orders
        @orders.should_receive(:for_option).with(5).and_return @orders
        @orders.should_receive(:page).with(nil).and_return @orders
      end
      describe "with option" do
        before do
          @option.should_receive(:find).with('5').and_return(@option)
          get :update_status, order_option: 5
        end
        specify { response.should render_template(:update_status) }
        specify { assigns[:option].should == @option }
        specify { assigns[:orders].should == @orders }
      end
      describe "without option" do
        before do
          @option.should_receive(:first).and_return(@option)
          get :update_status
        end
        specify { response.should render_template(:update_status) }
        specify { assigns[:option].should == @option }
        specify { assigns[:orders].should == @orders }
      end
    end

    describe 'new' do
      before do
        @order = Order.new
        Order.should_receive(:new).and_return(@order)
        get :new
      end
      specify { response.should render_template(:new) }
      specify { assigns[:order].should == @order }
      specify { assigns[:order].distributions.length.should == 4 }
      specify { assigns[:order].comments.length.should == 1 }
    end

    describe 'create' do
      let(:creator) { double('OrderCreator', perform: order) }
      before { OrderCreator.should_receive(:new).with(@current_user, 'params').and_return creator }
      describe 'successfully' do
        let(:order) { a_pretend(:order, id: 45) }
        before { post :create, order: 'params' }
        specify { response.should redirect_to(order_path(45)) }
        specify { flash[:notice].should == 'Order has been created' }
      end
      describe 'unsuccessfully' do
        let(:order) { Order.new }
        before { post :create, order: 'params' }
        specify { response.should render_template(:new) }
        specify { flash[:error].should == 'Could not save the order' }
        specify { assigns[:order].distributions.length.should == 4 }
        specify { assigns[:order].comments.length.should == 1 }
      end
    end

    describe 'copy' do
      let(:order) { Order.new }
      let(:accessor) { double('OrderAccessor', copy_order_with_id: order)}
      before do
        OrderAccessor.should_receive(:new).with(@current_user).and_return(accessor)
        get :copy, id: 45
      end
      specify { assigns[:order].should == order }
      specify { response.should render_template(:new) }
    end

    describe 'edit' do
      before do
        Order.should_receive(:accessible_by).with(@current_user).and_return(@order = Order.new)
        @order.should_receive(:find).with('45').and_return(@order)
        get :edit, id: '45'
      end
      specify { response.should render_template(:edit) }
      specify { assigns[:order].should == @order }
      specify { assigns[:order].comments.length.should == 1 }
      specify { assigns[:order].distributions.length.should == 4 }
    end

    describe 'update' do
      let(:updator) { double('OrderUpdator', perform: order) }
      before { OrderUpdator.should_receive(:new).with(@current_user, '45', 'stuff').and_return updator }
      describe 'successfully' do
        let(:order) { nil }
        before {post :update, id: '45', order: 'stuff'}
        specify { response.should redirect_to(order_path(45)) }
        specify { flash[:notice].should == 'Changes have been saved' }
      end
      describe 'unsuccessfully' do
        let(:order) { a_pretend(:order, changed?: true) }
        before {post :update, id: '45', order: 'stuff'}
        specify { response.should render_template(:edit) }
        specify { flash[:error].should == 'Could not save changes' }
        specify { assigns[:order].comments.length.should == 1 }
        specify { assigns[:order].distributions.length.should == 4 }
      end
    end

    describe 'destroy' do
      before { OrderDestroyer.should_receive(:new).with(@current_user, '12').and_return destroyer }
      let(:destroyer) { double('OrderDestroyer', perform: order) }
      describe 'successfully' do
        let(:order) { a_pretend(:order, destroyed?: true) }
        before { post :destroy, id: 12 }
        specify { response.should redirect_to(orders_path) }
        specify { flash[:notice].should == 'Order deleted successfully' }
      end
      describe 'unsuccessfully' do
        let(:order) { a_pretend(:order, destroyed?: false) }
        before { post :destroy, id: 12 }
        specify { response.should render_template(:edit) }
        specify { assigns[:order].should == order }
      end
    end
  end

  describe 'search' do
    before do
      Order.should_receive(:accessible_by).with(@current_user).and_return @orders = double
      @orders.should_receive(:search).with('xyz').and_return @orders
      @orders.should_receive(:page).with('2').and_return @orders
      get :search, {query: 'xyz', page: 2}
    end
    specify { response.should render_template(:search) }
    specify { assigns[:orders].should == @orders }
  end

  describe 'advanced' do
    before do
      Order.should_receive(:filter).with({'search' => 'xyz', 'page' => '2', 'action' => 'advanced', 'controller' => 'orders'}, @current_user).and_return @orders = double
      @orders.should_receive(:for_listing).and_return @orders
      @orders.should_receive(:page).with('2').and_return @orders
      get :advanced, {search: 'xyz', page: 2}
    end
    specify { response.should render_template(:index) }
    specify { assigns[:orders].should == @orders }
  end

  describe 'index' do
    before do
      @orders = [Order.new]
      @orders.should_receive(:accessible_by).with(@current_user).and_return(@orders)
      @orders.should_receive(:for_listing).and_return(@orders)
    end
    describe 'page 1' do
      before do
        @orders.should_receive(:page).with(nil).and_return(@orders)
        @orders.should_receive(:order_by).with(nil, nil).and_return(@orders)
      end
      describe 'current' do
        before do
          Order.should_receive(:for_current_period).and_return(@orders)
          get :index
        end
        specify { response.should render_template(:index) }
        specify { assigns[:orders].should == @orders }
      end
      describe 'all' do
        before do
          Order.should_receive(:where).with('1=1').and_return(@orders)
          get :index, type: 'all'
        end
        specify { response.should render_template(:index) }
        specify { assigns[:orders].should == @orders }
      end
      describe 'previous' do
        before do
          Order.should_receive(:for_previous_period).with(@current_user).and_return(@orders)
          get :index, type: 'previous'
        end
        specify { response.should render_template(:index) }
        specify { assigns[:orders].should == @orders }
      end
      describe 'next' do
        before do
          Order.should_receive(:for_next_period).with(@current_user).and_return(@orders)
          get :index, type: 'next'
        end
        specify { response.should render_template(:index) }
        specify { assigns[:orders].should == @orders }
      end
      describe 'duplicated' do
        before do
          Order.should_receive(:duplicates).and_return(@orders)
          get :index, type: 'duplicated'
        end
        specify { response.should render_template(:index) }
        specify { assigns[:orders].should == @orders }
      end
    end
    
    describe 'page 2' do
      before do
        @orders.should_receive(:page).with('2').and_return(@orders)
        @orders.should_receive(:order_by).with(nil, nil).and_return(@orders)
      end
      describe 'current' do
        before do
          Order.should_receive(:for_current_period).and_return(@orders)
          get :index, page: 2
        end
        specify { response.should render_template(:index) }
        specify { assigns[:orders].should == @orders }
      end
      describe 'all' do
        before do
          Order.should_receive(:where).with('1=1').and_return(@orders)
          get :index, type: 'all', page: 2
        end
        specify { response.should render_template(:index) }
        specify { assigns[:orders].should == @orders }
      end
      describe 'previous' do
        before do
          Order.should_receive(:for_previous_period).and_return(@orders)
          get :index, type: 'previous', page: 2
        end
        specify { response.should render_template(:index) }
        specify { assigns[:orders].should == @orders }
      end
      describe 'next' do
        before do
          Order.should_receive(:for_next_period).and_return(@orders)
          get :index, type: 'next', page: 2
        end
        specify { response.should render_template(:index) }
        specify { assigns[:orders].should == @orders }
      end
      describe 'duplicated' do
        before do
          Order.should_receive(:duplicates).and_return(@orders)
          get :index, type: 'duplicated', page: 2
        end
        specify { response.should render_template(:index) }
        specify { assigns[:orders].should == @orders }
      end
    end

    describe 'ordered' do
      before do
        @orders.should_receive(:page).with('2').and_return(@orders)
        @orders.should_receive(:order_by).with('total_price', 'asc').and_return(@orders)
      end
      describe 'current' do
        before do
          Order.should_receive(:for_current_period).and_return(@orders)
          get :index, page: 2, sort: 'total_price', direction: 'asc'
        end
        specify { response.should render_template(:index) }
        specify { assigns[:orders].should == @orders }
      end
      describe 'all' do
        before do
          Order.should_receive(:where).with('1=1').and_return(@orders)
          get :index, type: 'all', page: 2, sort: 'total_price', direction: 'asc'
        end
        specify { assigns[:orders].should == @orders }
        specify { response.should render_template(:index) }
      end
      describe 'previous' do
        before do
          Order.should_receive(:for_previous_period).and_return(@orders)
          get :index, type: 'previous', page: 2, sort: 'total_price', direction: 'asc'
        end
        specify { response.should render_template(:index) }
        specify { assigns[:orders].should == @orders }
      end
      describe 'next' do
        before do
          Order.should_receive(:for_next_period).and_return(@orders)
          get :index, type: 'next', page: 2, sort: 'total_price', direction: 'asc'
        end
        specify { response.should render_template(:index) }
        specify { assigns[:orders].should == @orders }
      end
      describe 'duplicated' do
        before do
          Order.should_receive(:duplicates).and_return(@orders)
          get :index, type: 'duplicated', page: 2, sort: 'total_price', direction: 'asc'
        end
        specify { response.should render_template(:index) }
        specify { assigns[:orders].should == @orders }
      end
    end
  end

  describe 'index when order has client missing' do
    before do
      @current_user.user_type = User::ADMIN
      @current_user.department = FactoryGirl.create(:department)

      store = FactoryGirl.create :store
      period = FactoryGirl.create :period, client: store.client
      order = FactoryGirl.create :order, period: period, store: store

      period.client.delete
    end

    render_views

    it 'does not raise an error' do
      expect do
        get :index
      end.not_to raise_error
    end
  end

  describe 'show' do
    before do
      Order.should_receive(:accessible_by).with(@current_user).and_return(@order = Order.new)
      @order.should_receive(:includes).with(:store => :address).and_return(@order)
      @order.should_receive(:find).with('45').and_return(@order)
      get :show, id: '45'
    end
    specify { response.should render_template(:show) }
    specify { assigns[:order].should == @order }
  end

  describe 'notes' do
    before do
      Order.should_receive(:accessible_by).with(@current_user).and_return @order = double
      @order.should_receive(:find).with('12').and_return @order
      @order.should_receive(:comments).and_return(@comments = [Comment.new])
      @comments.should_receive(:ordered).and_return(@comments)
      @comments.should_receive(:page).with('2').and_return(@comments)
      get :notes, id: 12, page: 2
    end
    specify { response.should render_template(:notes) }
    specify { assigns[:comments].should == @comments }
    specify { assigns[:order].should == @order }
  end  
end