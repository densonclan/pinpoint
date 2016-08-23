# ./spec/models/distribution_spec.rb
require 'spec_helper'

describe Distribution do
  describe 'validations' do
    before { @distribution = Distribution.new total_quantity: 5000, distribution_week: -1, ship_via: Distribution::SHIP_VIA_NEP }
    describe 'valid' do
      specify { @distribution.should be_valid }
    end
    describe 'missing quantity' do
      before { @distribution.total_quantity = 0 }
      specify { @distribution.should_not be_valid }
    end
    describe 'invalid week' do
      before { @distribution.distribution_week = "invalid" }
      specify { @distribution.should_not be_valid }
    end
  end

  describe 'covert postcodes' do
    before { @distribution = Distribution.new }
    describe 'without postcode ids' do
      before { @distribution.valid? }
      specify { @distribution.distribution_postcodes.should be_empty }
    end
    describe 'with new postcodes' do
      before do
        @distribution.postcode_ids = '4,6,19'
        @distribution.valid?
      end
      specify { @distribution.distribution_postcodes.map {|p| p.postcode_sector_id}.should == [4,6,19] }
    end
    describe 'with existing postcodes' do
      before do
        @distribution.distribution_postcodes = [@dp = DistributionPostcode.new(postcode_sector_id: 13)]
        @distribution.postcode_ids = '4,6,19'
        @distribution.valid?
      end
      specify { @distribution.distribution_postcodes.map {|p| p.postcode_sector_id}.should == [13,4,6,19] }
      specify { @dp.should be_marked_for_destruction }
    end
  end

  context '#calculate_box_count' do
    let(:order) { Order.new }
    let(:distribution) {
      distribution = Distribution.new(total_quantity: 1600)
      distribution.order = order
      distribution
    }
    let(:page) { Page.new }
    subject { distribution.calculate_box_count }
    describe 'without order page' do
      it { should be_nil }
    end
    describe 'without page box quantity' do
      before { order.stub(:page).and_return page }
      it { should be_nil }
    end
    describe 'with page box quantity' do
      let(:page) { Page.new box_quantity: 500 }
      before { order.stub(:page).and_return page }
      it { should == 4 }
    end
  end

  describe 'store_own_delivery' do
    it 'should return true when it is store own delivery' do
      distribution = Distribution.new(distributor_id: Distribution::STORE_OWN_DELIVERY)
      distribution.store_own_delivery?.should be
    end

    it 'should return false when it is not store own delivery' do
      distribution = Distribution.new(distributor_id: Distribution::IN_STORE)
      distribution.store_own_delivery?.should_not be
    end
  end

  describe 'filter' do
    before(:all) do
      @admin = create_a(:just_user, client_id: 4, user_type: User::ADMIN)
      @user = create_a(:just_user, client_id: 1, user_type: User::READ_ONLY)
      @user2 = create_a(:just_user, client_id: 2, user_type: User::CLIENT)
      @store1 = create_a(:store, client_id: 1)
      @order1 = create_a(:order, period_id: 1, option_id: 3, status: Order::AWAITING_PRINT, store_id: @store1.id, distributions: [@distribution1 = create_a(:distribution, distributor_id: Distribution::IN_STORE)])
      @order2 = create_a(:order, period_id: 2, option_id: 5, status: Order::IN_PRINT, store_id: @store1.id, distributions: [@distribution2 = create_a(:distribution, distributor_id: Distribution::SOLUS_TEAM), @distribution3 = create_a(:distribution, distributor_id: Distribution::ROYAL_MAIL)])
    end
    after(:all) do
      delete_all %w(users orders distributions stores)
    end
    describe 'for admin' do
      specify { Distribution.filter({}, @admin).sort.should == [@distribution1, @distribution2, @distribution3].sort}
      specify { Distribution.filter({order_status: [Order::AWAITING_PRINT, Order::COMPLETED]}, @admin).should == [@distribution1]}
      specify { Distribution.filter({order_option: [5,4]}, @admin).sort.should == [@distribution2, @distribution3].sort}
      specify { Distribution.filter({order_distributor: [Distribution::IN_STORE, Distribution::NEWSPAPER]}, @admin).should == [@distribution1]}
      specify { Distribution.filter({order_period: [2,3]}, @admin).sort.should == [@distribution2, @distribution3].sort}
      specify { Distribution.filter({order_period: [2], order_distributor: [Distribution::ROYAL_MAIL]}, @admin).should == [@distribution3]}
      specify { Distribution.filter({order_option: [3], order_distributor: [Distribution::ROYAL_MAIL]}, @admin).should == []}
    end
    describe 'for user' do
      specify { Distribution.filter({}, @user).sort.should == [@distribution1, @distribution2, @distribution3].sort}
      specify { Distribution.filter({order_status: [Order::AWAITING_PRINT, Order::COMPLETED]}, @user).should == [@distribution1]}
      specify { Distribution.filter({order_option: [5,4]}, @user).sort.should == [@distribution2, @distribution3].sort}
      specify { Distribution.filter({order_distributor: [Distribution::IN_STORE, Distribution::NEWSPAPER]}, @user).should == [@distribution1]}
      specify { Distribution.filter({order_period: [2,3]}, @user).sort.should == [@distribution2, @distribution3].sort}
      specify { Distribution.filter({order_period: [2], order_distributor: [Distribution::ROYAL_MAIL]}, @user).should == [@distribution3]}
      specify { Distribution.filter({order_option: [3], order_distributor: [Distribution::ROYAL_MAIL]}, @user).should == []}
    end
    describe 'for invalid user' do
      specify { Distribution.filter({}, @user2).should == []}
      specify { Distribution.filter({order_option: [5,4]}, @user2).should == []}
    end
  end
end