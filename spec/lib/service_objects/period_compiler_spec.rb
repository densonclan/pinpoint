require 'spec_helper'

describe PeriodCompiler do

  describe 'compile!' do
    let(:client) { create_a(:client) }
    let(:user) { create_a(:user, client: client) }
    let(:store1) { create_a(:store, client: client) }
    let(:store2) { create_a(:store, client: client) }
    let!(:order1) { create_a(:order, store: store1, period: period, total_price: 1) }
    let!(:order2) { create_a(:order, store: store2, period: period, total_price: 2) }
    let!(:skipped_order) { create_a(:order, period: period, total_price: 3) }
    let!(:existing_order) { create_a(:order, store: store1, period: next_period, total_price: 4) }
    let!(:order_exception) { OrderException.create(order: skipped_order, period: period) }
    let(:period) { create_a(:period, client: client, current: false, year: 2014, period_number: 9) }
    let!(:next_period) { create_a(:period, client: client, current: false, year: 2014, period_number: 10)}

    subject { PeriodCompiler.new(user.id, period.id.to_s).perform }

    describe 'when locked' do
      let(:period) { create_a(:period, client: client, current: true, locked: true, year: 2014, period_number: 9) }
      it 'should do nothing' do
        subject.should be_nil
        period.should_not be_completed
        period.should be_locked
        Order.count.should == 4
      end
    end

    describe 'when not current' do
      it 'should do nothing' do
        subject.should be_nil
        period.should_not be_completed
        Order.count.should == 4
      end
    end
    describe 'when current' do
      let(:period) { create_a(:period, client: client, current: true, year: 2014, period_number: 9) }
      it 'should copy the orders to the next period' do
        subject.should be_true
        period.reload
        period.should be_completed
        period.should_not be_current
        period.next_period.should_not be_completed
        period.next_period.should be_current
        period.should_not be_locked
        Order.count.should == 5
        period.next_period.orders.reload.map {|o| o.total_price}.sort.should == [2,4]
      end
    end
  end
end