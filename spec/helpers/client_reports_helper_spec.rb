require 'spec_helper'

describe ClientReportsHelper do

  describe 'order_count_for_client' do
    let(:client) { FactoryGirl.create :client }
    describe 'with no periods' do
      specify { order_count_for_client(client).should == []}
    end

    describe 'with periods' do
      before do
        FactoryGirl.create :period, period_number: 2, client: client
        FactoryGirl.create :period, period_number: 3, client: client
        FactoryGirl.create :period, period_number: 4, client: client
        self.should_receive(:report_client_period_count).with(client, '2').and_return 10
        self.should_receive(:report_client_period_count).with(client, '3').and_return 7
        self.should_receive(:report_client_period_count).with(client, '4').and_return 80
      end
      specify { order_count_for_client(client).should == [ ['2', 10], ['3', 7], ['4', 80] ] }
    end
  end

  describe 'report_client_period_count' do
    before { @client = Client.new }
    describe 'without period' do
      before { @client.should_receive(:period).with(5).and_return nil }
      specify { report_client_period_count(@client, 5).should == 0 }
    end
    describe 'with period' do
      before do
        self.should_receive(:client_orders_per_period).and_return({1 => 50, 4 => 40, 6 => 56, 7 => 43})
      end
      describe 'without order count' do
        before { @client.should_receive(:period).with(5).and_return double(id: 2) }
        specify { report_client_period_count(@client, 5).should == 0 }
      end
      describe 'with order count' do
        before { @client.should_receive(:period).with(5).and_return double(id: 7) }
        specify { report_client_period_count(@client, 5).should == 43 }
      end
    end
  end

  describe 'client_orders_per_period' do
    before do
      self.should_receive(:calculate_orders_per_period).and_return true
      client_orders_per_period # check the double is only called once
    end
    specify { client_orders_per_period.should be_true }
  end

  describe 'calculate_orders_per_period' do
    before do
      self.should_receive(:current_user).and_return @user = User.new
      @orders = [double(period_id: 2, total_quantity: 200), double(period_id: 3, total_quantity: 450), double(period_id: 5, total_quantity: 600)]
      Order.should_receive(:accessible_by).with(@user).and_return @orders
      @orders.should_receive(:count_by_period).and_return @orders
    end
    specify { calculate_orders_per_period.should == {2 => 200, 3 => 450, 5 => 600} }
  end
end