# ./spec/models/periods_spec.rb
require 'spec_helper'

describe Period do

  describe 'attr_accessible' do
    before { @period = Period.new date_approval: '2013-12-01', date_dispatch: '2013-12-14', date_print: '2013-12-07', date_promo: '2013-12-18', date_promo_end: '2013-12-20', date_samples: '2013-12-25', period_number: 6, week_number: 55, current: true, completed: true, client_id: 12, year: 2013 }
    specify { @period.date_approval.should == Date.new(2013, 12, 1) }
    specify { @period.date_dispatch.should == Date.new(2013, 12, 14) }
    specify { @period.date_print.should == Date.new(2013, 12, 7) }
    specify { @period.date_promo.should == Date.new(2013, 12, 18) }
    specify { @period.date_promo_end.should == Date.new(2013, 12, 20) }
    specify { @period.date_samples.should == Date.new(2013, 12, 25) }
    specify { @period.period_number.should == 6 }
    specify { @period.week_number.should == 55 }
    specify { @period.current.should be_true }
    specify { @period.completed.should be_true }
    specify { @period.client_id.should == 12 }
    specify { @period.year.should == 2013 }
  end

  describe 'validations' do
    before do
      @period = Period.new(period_number: 12, year: 2013, week_number: 355, date_promo: '2013-12-20', date_dispatch: '2013-12-14')
      @period.client = Client.new
    end
    describe 'is valid with attributes' do
      specify { @period.should be_valid }
    end
    describe 'invalid week number' do
      before { @period.week_number = 0 }
      specify { @period.should_not be_valid }
    end
    describe 'missing date_promo' do
      before { @period.date_promo = nil }
      specify { @period.should_not be_valid }
    end
    describe 'missing date_dispatch' do
      before { @period.date_dispatch = nil }
      specify { @period.should_not be_valid }
    end
    describe 'missing client' do
      before { @period.client = nil }
      specify { @period.should_not be_valid }
    end
    describe 'invalid year' do
      before { @period.year = 2012 }
      specify { @period.should_not be_valid }
    end
    describe 'missing year' do
      before { @period.year = nil }
      specify { @period.should_not be_valid }
    end
    describe 'duplicate period number' do
      before do
        client = FactoryGirl.create(:client)
        @period.client = client
        FactoryGirl.create(:period, client: client, year: 2013, period_number: 12)
      end
      specify { @period.should_not be_valid }
    end
    context 'when period_number starts from char' do
      before { @period.period_number = 'a1' }
      it { expect(@period).to be_valid }
    end
    context 'when period_number has no digits' do
      before { @period.period_number = 'abc' }
      it { expect(@period).not_to be_valid }
    end
    context 'when period_number has 2 points' do
      before { @period.period_number = '1.2.3' }
      it { expect(@period).not_to be_valid }
    end
  end

  describe 'default current' do
    describe 'when not set' do
      before do
        @period = Period.new
        @period.valid?
      end
      specify { @period.current.should === false }
    end
    describe 'when set' do
      before do
        @period = Period.new(current: true)
        @period.valid?
      end
      specify { @period.current.should === true }
    end
  end

  describe 'next and previous periods' do
    before(:all) do
      @client = FactoryGirl.create(:client)
      @period1 = FactoryGirl.create(:period, year: 2013, period_number: 16, client: @client)
      @period2 = FactoryGirl.create(:period, year: 2013, period_number: 17, client: @client)
      @period3 = FactoryGirl.create(:period, year: 2014, period_number: 1, client: @client)
      @period4 = FactoryGirl.create(:period, year: 2014, period_number: 2, client: @client)
      @period5 = FactoryGirl.create(:period, year: 2014, period_number: "2.5", client: @client)
      @period6 = FactoryGirl.create(:period, year: 2014, period_number: 3, client: @client)
      @period7 = FactoryGirl.create(:period, year: 2014, period_number: "3.1b", client: @client)
      @period8 = FactoryGirl.create(:period, year: 2014, period_number: 3.2, client: @client)
      @random  = FactoryGirl.create(:period, year: 2014, period_number: 1)
    end
    after(:all) { delete_all %w(periods clients) }
    specify { @period1.previous_period.should be_nil }
    specify { @period2.previous_period.should == @period1 }
    specify { @period3.previous_period.should == @period2 }
    specify { @period4.previous_period.should == @period3 }
    specify { @period1.next_period.should == @period2 }
    specify { @period2.next_period.should == @period3 }
    specify { @period3.next_period.should == @period4 }
    specify { @period4.next_period.should == @period5 }
    specify { @period5.next_period.should == @period6 }
    specify { @period6.next_period.should == @period7 }
    specify { @period7.next_period.should == @period8 }
    specify { @period8.next_period.should be_nil }
  end
end
