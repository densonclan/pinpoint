# ./spec/models/orders_spec.rb
require 'spec_helper'

describe Order do
  before(:each) do
    @order = FactoryGirl.build(:order)
  end

  it 'should have default status' do
    order_new = Order.new
    order_new.status.should == 0
  end

  it 'should have status below 3' do
    @order.status = 4
    @order.should_not be_valid
  end

  it 'should parse distribution weeks for each distribution' do
    #
    # => Build distribution with Quantity of 1200
    #
    @distro = FactoryGirl.build(:royal_distribution)
    @order.distributions << @distro

    #
    # When saving
    #
    @order.save!
    @order.distributions[0].distribution_week.should == 0
  end

  describe 'scopes' do
    describe 'for_status' do
      before do
        @order1 = create_a(:order, status: 1)
        @order2 = create_a(:order, status: 2)
        @order3 = create_a(:order, status: 2)
        @order4 = create_a(:order, status: 3)
      end
      specify { Order.for_status([2,3]).should == [@order2, @order3, @order4] }
    end
    describe 'for_option' do
      before do
        @order1 = create_a(:order, option_id: 1)
        @order2 = create_a(:order, option_id: 2)
        @order3 = create_a(:order, option_id: 2)
        @order4 = create_a(:order, option_id: 3)
      end
      specify { Order.for_option([1,2]).should == [@order1, @order2, @order3] }
    end
    describe 'for_period' do
      before do
        @order1 = create_a(:order, period_id: 1)
        @order2 = create_a(:order, period_id: 2)
        @order3 = create_a(:order, period_id: 2)
        @order4 = create_a(:order, period_id: 3)
      end
      specify { Order.for_period([1,2]).should == [@order1, @order2, @order3] }
    end

    describe 'distributions' do
      before do
        @order1 = create_a(:order, distributions: [create_a(:distribution, distributor_id: 1, ship_via: 'G&H')])
        @order2 = create_a(:order, distributions: [create_a(:distribution, distributor_id: 1), create_a(:distribution, distributor_id: 2, ship_via: 'G&H')])
        @order3 = create_a(:order, distributions: [create_a(:distribution, distributor_id: 2)])
      end
      describe 'for_distribution' do
        specify { Order.for_distribution(1).map {|o| o.id}.sort.should == [@order1.id, @order2.id].sort }
        specify { Order.for_distribution([1, 2]).map {|o| o.id}.sort.should == [@order1.id, @order2.id, @order3.id].sort }
      end
      describe 'for_ship_via' do
        specify { Order.for_ship_via('G&H').map {|o| o.id}.sort.should == [@order1.id, @order2.id].sort }
      end
    end

    describe 'participation only' do
      before do
        @store1 = create_a(:store, participation_only: true)
        @store2 = create_a(:store)
        @order1 = create_a(:order, store: @store1)
        @order2 = create_a(:order, store: @store1)
        @order3 = create_a(:order, store: @store2)
      end
      specify { Order.for_participation_only_stores.map {|o| o.id}.sort.should == [@order1.id, @order2.id].sort }
    end

    describe 'for_store_without_logo' do
      before do
        @store1 = create_a(:store, logo: "123456")
        @store2 = create_a(:store, logo: nil)
        @order1 = create_a(:order, store: @store1)
        @order2 = create_a(:order, store: @store2)
      end

      it 'should return order with store not having any logo' do
        Order.for_store_without_logo.should include(@order2)
      end

      it 'should not return order with store having a logo' do
        Order.for_store_without_logo.should_not include(@order1)
      end
    end

    describe 'periods' do
      let(:client) { FactoryGirl.create :client }
      let(:user) { FactoryGirl.create :user, client: client }
      let(:store) { FactoryGirl.create :store, client: client }

      let!(:previous_period) { FactoryGirl.create :period, period_number: 1, current: false, client: client }
      let!(:current_period) { FactoryGirl.create :period, period_number: 2, current: true, client: client }
      let!(:next_period) { FactoryGirl.create :period, period_number: 3, current: false, client: client }

      let!(:order_from_previous_period) { FactoryGirl.create :order, period: previous_period, user: user, store: store }
      let!(:order_from_current_period) { FactoryGirl.create :order, period: current_period, user: user, store: store }
      let!(:order_from_next_period) { FactoryGirl.create :order, period: next_period, user: user, store: store }
      describe 'for_next_period' do
        subject { Order.for_next_period(user) }

        it { should_not include order_from_previous_period }
        it { should_not include order_from_current_period }
        it { should include order_from_next_period }
      end

      describe 'for_previous_period' do
        subject { Order.for_previous_period(user) }

        it { should include order_from_previous_period }
        it { should_not include order_from_current_period }
        it { should_not include order_from_next_period }
      end
    end
  end

  describe 'destroy' do
    let(:distribution) { create_a(:distribution) }
    let(:order) { create_a(:order, distributions: [distribution]) }
    before { order.destroy }
    it 'should destroy the order' do
      Order.count.should be_zero
      Distribution.count.should be_zero
    end
  end

  describe "duplicates" do
    before do
      @o1 = FactoryGirl.create(:order, store_id: 1, period_id: 1)
      @o2 = FactoryGirl.create(:order, store_id: 1, period_id: 2)
      @o3 = FactoryGirl.create(:order, store_id: 2, period_id: 1)
      @o4 = FactoryGirl.create(:order, store_id: 1, period_id: 1)
      @o5 = FactoryGirl.create(:order, store_id: 2, period_id: 2)
    end
    specify { Order.duplicates.map{|o| o.id}.sort.should == [@o1.id, @o4.id].sort}
  end

  describe 'status_text' do
    specify { FactoryGirl.build(:order, status: 0).status_text.should == 'Awaiting Print' }
    specify { FactoryGirl.build(:order, status: 1).status_text.should == 'Completed' }
    specify { FactoryGirl.build(:order, status: 2).status_text.should == 'In Print' }
    specify { FactoryGirl.build(:order, status: 3).status_text.should == 'Dispatched' }
    specify { FactoryGirl.build(:order, status: 4).status_text.should == '' }
  end

  describe 'for current period' do
    before do
      @current_period_1   = FactoryGirl.create(:period, current: true)
      @not_current_period = FactoryGirl.create(:period, current: false)
      @current_period_2   = FactoryGirl.create(:period, current: true)
      @o1 = create_a(:order, period: @current_period_1)
      @o2 = create_a(:order, period: @not_current_period)
      @o3 = create_a(:order, period: @current_period_1)
      @o4 = create_a(:order, period: @current_period_2)
    end
    specify { Order.for_current_period.order(:id).should == [@o1, @o3, @o4] }
  end

  describe 'box counts' do
    let(:distribution1) { a_pretend(:distribution, ship_via: Distribution::SHIP_VIA_GH, total_quantity: 4700) }
    let(:distribution2) { a_pretend(:distribution, ship_via: Distribution::SHIP_VIA_NEP, total_quantity: 8500) }
    let(:distribution3) { a_pretend(:distribution, ship_via: Distribution::SHIP_VIA_NEP, total_quantity: 6000) }
    let(:distribution4) { a_pretend(:distribution, ship_via: nil, total_quantity: 5000) }
    let(:distributions) { [distribution1, distribution2, distribution3, distribution4] }
    let(:page) { a_pretend(:page, box_quantity: 400) }
    let(:order) { a_pretend(:order, distributions: distributions, page: page) }

    context '#total_nep_boxes' do
      specify { order.total_nep_boxes.should == 37 } 
    end

    context '#total_gh_boxes' do
      specify { order.total_gh_boxes.should == 12 } 
    end

    context '#calculate_box_count' do
      specify { order.calculate_box_count.should == 1 }
    end
  end

  describe '#calculate_box_count' do
    let(:distribution1) { a_pretend(:distribution, ship_via: Distribution::SHIP_VIA_GH, total_quantity: 4700) }
    let(:distributions) { [distribution1] }
    let(:page) { a_pretend(:page, box_quantity: 400) }
    let(:total_quantity) { 400 }
    let(:order) { a_pretend(:order, distributions: distributions, page: page, total_quantity: total_quantity) }

    context 'no page' do
      let(:page) { nil }
      specify { order.calculate_box_count.should == nil }
    end

    context '1 box' do
      specify { order.calculate_box_count.should == 1 }
    end

    context 'miltible boxes' do
      let(:total_quantity) { 1111 }
      specify { order.calculate_box_count.should == 3 }
    end
  end

  describe '#having_part_box?' do
    let(:distribution1) { a_pretend(:distribution, ship_via: Distribution::SHIP_VIA_GH, total_quantity: 4700) }
    let(:distributions) { [distribution1] }
    let(:page) { a_pretend(:page, box_quantity: 400) }
    let(:total_quantity) { 400 }
    let(:order) { a_pretend(:order, distributions: distributions, page: page, total_quantity: total_quantity) }

    context 'no page' do
      let(:page) { nil }
      specify { order.having_part_box?.should_not be }
    end

    context 'doesnt have part box' do
      specify { order.having_part_box?.should_not be }
    end

    context 'has part box' do
      let(:total_quantity) { 1111 }
      specify { order.having_part_box?.should be }
    end
  end

  describe 'filter' do
    before(:all) do
      @admin = create_a(:just_user, client_id: 4, user_type: User::ADMIN)
      @user = create_a(:just_user, client_id: 1, user_type: User::READ_ONLY)
      @user2 = create_a(:just_user, client_id: 2, user_type: User::CLIENT)
      @store1 = create_a(:store, client_id: 1)
      @store2 = create_a(:store, client_id: 1)
      @order1 = create_a(:order, period_id: 1, option_id: 3, status: Order::AWAITING_PRINT, store_id: @store1.id, distributions: [create_a(:distribution, distributor_id: Distribution::IN_STORE)])
      @order2 = create_a(:order, period_id: 2, option_id: 5, status: Order::IN_PRINT, store_id: @store1.id, distributions: [create_a(:distribution, distributor_id: Distribution::SOLUS_TEAM), create_a(:distribution, distributor_id: Distribution::ROYAL_MAIL)])
      @order3 = create_a(:order, period_id: 2, option_id: 7, status: Order::COMPLETED, store_id: @store2.id, distributions: [create_a(:distribution, distributor_id: Distribution::SOLUS_TEAM)])
    end
    after(:all) do
      delete_all %w(users orders distributions stores)
    end
    describe 'for admin' do
      specify { Order.filter({}, @admin).sort.should == [@order1, @order2, @order3].sort}
      specify { Order.filter({order_status: [Order::AWAITING_PRINT, Order::COMPLETED]}, @admin).sort.should == [@order1, @order3].sort}
      specify { Order.filter({order_option: [5,4]}, @admin).should == [@order2]}
      specify { Order.filter({order_distributor: [Distribution::IN_STORE, Distribution::NEWSPAPER]}, @admin).should == [@order1]}
      specify { Order.filter({order_period: [2,3]}, @admin).should == [@order2, @order3]}
      specify { Order.filter({order_period: [2], order_distributor: [Distribution::ROYAL_MAIL]}, @admin).should == [@order2]}
      specify { Order.filter({order_option: [3], order_distributor: [Distribution::ROYAL_MAIL]}, @admin).should == []}
    end
    describe 'for user' do
      specify { Order.filter({}, @user).sort.should == [@order1, @order2, @order3].sort}
      specify { Order.filter({order_status: [Order::AWAITING_PRINT, Order::COMPLETED]}, @user).sort.should == [@order1, @order3].sort}
      specify { Order.filter({order_option: [5,4]}, @user).sort.should == [@order2].sort}
      specify { Order.filter({order_distributor: [Distribution::IN_STORE, Distribution::NEWSPAPER]}, @user).should == [@order1]}
      specify { Order.filter({order_period: [2,3]}, @user).sort.should == [@order2, @order3].sort}
      specify { Order.filter({order_period: [2], order_distributor: [Distribution::ROYAL_MAIL]}, @user).should == [@order2]}
      specify { Order.filter({order_option: [3], order_distributor: [Distribution::ROYAL_MAIL]}, @user).should == []}
    end
    describe 'for invalid user' do
      specify { Order.filter({}, @user2).should == []}
      specify { Order.filter({order_option: [5,4]}, @user2).should == []}
    end
  end
end
