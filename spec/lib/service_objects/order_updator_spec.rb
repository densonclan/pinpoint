require 'spec_helper'

describe OrderUpdator do

  let(:client) { create_a(:client) }
  let(:user) { create_a(:just_user) }
  let(:store) { create_a(:store, client: client) }
  let(:period) { create_a(:period, client: client) }
  let(:distribution) { create_a(:distribution, total_quantity: 4000, distribution_week: -1, distributor_id: Distribution::IN_STORE) }
  let(:order) { create_a(:order, total_price: 1234, store: store, period: period, distributions: [distribution]) }

  context '#perform' do
    subject { OrderUpdator.new(user, order.id.to_s, attributes).perform }

    describe 'new period' do
      let(:period2) { create_a(:period, client: client) }
      let(:attributes) { {"total_price"=>'2323', "period_id"=>period2.id.to_s} }
      it 'should duplicate the order' do
        subject.should be_nil
        Order.count.should == 2
        Distribution.count.should == 2

        new_order = Order.order(:id).last
        order.total_price.should == 1234
        order.period.should == period
        new_order.total_price.should == 2323
        new_order.period.should == period2
        distribution = new_order.distributions.first
        distribution.total_quantity.should == 4000
        distribution.distribution_week.should == -1
        distribution.distributor_id.should == Distribution::IN_STORE
      end
    end

    describe 'without lock' do
      let(:attributes) { {"total_price"=>'9999'} }
      it 'should not update the order' do
        subject.should be_changed
      end
    end

    describe 'with lock' do
      before { order.lock!(user) }
      describe 'same period' do
        let(:attributes) { {"total_price"=>'2323', "period_id"=>period.id.to_s} }
        it 'should update the order' do
          subject.should be_nil
          Order.count.should == 1
          Distribution.count.should == 1
          existing_order = Order.first
          existing_order.total_price.should == 2323
          existing_order.period.should == period
        end
      end

      describe 'no period given' do
        let(:attributes) { {"total_price"=>'9999'} }
        it 'should update the order' do
          subject.should be_nil
          Order.count.should == 1
          Distribution.count.should == 1
          existing_order = Order.first
          existing_order.total_price.should == 9999
          existing_order.period.should == period
        end
      end
    end
  end
end