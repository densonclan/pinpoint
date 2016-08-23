require 'spec_helper'

describe DistributorsHelper do

  describe 'distribution_weeks' do
    describe 'with period' do
      specify { distribution_weeks(double('Period', date_promo: Date.new(2013, 10, 21), week_number: 444)).should == [["2 Weeks before promo (w/c 07 Oct 2013)", -2], ['Week before promo (w/c 14 Oct 2013)', -1], ['Week of promo (w/c 21 Oct 2013)', 0], ['Week after promo (w/c 28 Oct 2013)', 1], ["2 Weeks after promo (w/c 04 Nov 2013)", 2]]}
    end
    describe 'without period' do
      specify { distribution_weeks.should == [["2 Weeks before promo", -2], ["Week before promo", -1], ["Week of promo", 0], ["Week after promo", 1], ["2 Weeks after promo", 2]]}
    end
  end

  describe 'distribution_leaflet' do
    before do
      @order = double('Order', period: double('Period', week_number: 334))
      @distribution = Distribution.new(distribution_week: -1)
    end
    describe 'with reference number' do
      before { @distribution.reference_number = '123' }
      specify { distribution_leaflet(@order, @distribution).should == '333/123'}
    end
    describe 'without reference number' do
      specify { distribution_leaflet(@order, @distribution).should == '&nbsp;'}
    end
  end

  describe 'distribution_week' do
    before { self.should_receive(:distribution_week_description).with(-1).and_return '\_/' }
    specify { distribution_week(double('Period', date_promo: Date.new(2013, 10, 21)), -1).should == '\_/ (w/c 14 Oct 2013)' }
  end

  describe 'distribution_week_description' do
    specify { distribution_week_description(-1).should == 'Week before promo' }
    specify { distribution_week_description(0).should == 'Week of promo' }
    specify { distribution_week_description(1).should == 'Week after promo' }
    specify { distribution_week_description(-2).should == '2 Weeks before promo' }
  end
end