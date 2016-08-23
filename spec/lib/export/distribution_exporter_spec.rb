require 'spec_helper'

describe DistributionExporter do
  let(:user) { FactoryGirl.create(:user) }
  let(:options) { {} }

  describe '::DistributionRow' do

    let(:period) { FactoryGirl.create(:period, id: 4) }
    let(:order) { create_a(:order, period_id: period.id) }

    describe 'comparison' do
      let!(:distribution1) { FactoryGirl.create(:royal_distribution, ship_via: Distribution::SHIP_VIA_NEP, order: order, distributor: Distributor.new(id: 100, name: 'something')) }
      let!(:distribution2) { FactoryGirl.create(:royal_distribution, ship_via: Distribution::SHIP_VIA_STORE, order: order, distributor: Distributor.new(id: 1)) }

      let(:options) { { period: distribution1.order.period_id } }

      it 'not break for unknown distribution type' do
        distribution1.distributor_id = 1
        row1 = DistributionExporter::DistributionRow.new(distribution1, period, ["In Store week of promo"])
        row2 = DistributionExporter::DistributionRow.new(distribution2, period, ["In Store week of promo"])
        [row1, row2].sort.should == [row1, row2]
      end

      it 'sort for known distribution type' do
        distribution1.distributor_id = 1
        distribution2.distributor_id = 2
        row1 = DistributionExporter::DistributionRow.new(distribution1, period, ["In Store week of promo"])
        row2 = DistributionExporter::DistributionRow.new(distribution2, period, ["In Store week of promo"])
        [row1, row2].sort.should == [row1, row2]
      end
    end
  end

end