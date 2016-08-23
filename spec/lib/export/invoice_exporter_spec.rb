require 'spec_helper'

describe InvoiceExporter do
  let(:user) { FactoryGirl.create(:user) }
  let(:options) { {} }

  subject { InvoiceExporter.new(user, options) }

  describe '#all_distributions' do
    let(:period) { FactoryGirl.create(:period, id: 4) }
    let(:order) { create_a(:order, period_id: period.id) }

    let!(:distribution1) { FactoryGirl.create(:royal_distribution, ship_via: Distribution::SHIP_VIA_NEP, order: order) }
    let!(:distribution2) { FactoryGirl.create(:royal_distribution, ship_via: Distribution::SHIP_VIA_NEP, order: order) }

    let(:options) { { period: distribution1.order.period_id } }

    it 'should return store row for distribution' do
      subject.all_distributions.length.should == 1
    end

    it 'should group store row for distribution by store' do
      another_period = FactoryGirl.create(:period, id: 5)
      another_order = create_a(:order, period_id: period.id)

      FactoryGirl.create(:royal_distribution, ship_via: Distribution::SHIP_VIA_NEP, order: another_order)
      subject.all_distributions.length.should == 2
    end
  end

  describe 'StoreRow' do
    let(:period) { FactoryGirl.create(:period, id: 4) }
    let(:order) { create_a(:order, period_id: period.id, total_quantity: 838) }

    let!(:distribution1) { FactoryGirl.create(:distribution, ship_via: Distribution::SHIP_VIA_NEP, order: order, distributor_id: Distribution::IN_STORE, total_quantity: 2) }
    let!(:distribution2) { FactoryGirl.create(:distribution, ship_via: Distribution::SHIP_VIA_NEP, order: order, distributor_id: Distribution::IN_STORE, total_quantity: 10) }
    let!(:distribution3) { FactoryGirl.create(:distribution, ship_via: Distribution::SHIP_VIA_NEP, order: order, distributor_id: Distribution::ROYAL_MAIL, total_quantity: 15) }
    let!(:distribution4) { FactoryGirl.create(:distribution, ship_via: Distribution::SHIP_VIA_NEP, order: order, distributor_id: Distribution::SOLUS_TEAM, total_quantity: 800) }
    let!(:distribution5) { FactoryGirl.create(:distribution, ship_via: Distribution::SHIP_VIA_NEP, order: order, distributor_id: Distribution::NEWSPAPER, total_quantity: 11) }

    subject { InvoiceExporter::StoreRow.new([distribution1, distribution2, distribution3, distribution4, distribution5], period) }

    describe '#value' do
      it 'should return account number' do
        subject.value('Store-Account Number').should == order.store.account_number
      end
      it 'should return total store delivery' do
        subject.value('Total store delivery').should == 12
      end
      it 'should return total royal mail' do
        subject.value('Total royal mail').should == 15
      end
      it 'should return total newspaper' do
        subject.value('Total newspaper').should == 11
      end
      it 'should return total solus' do
        subject.value('Total solus').should == 800
      end
      it 'should return account number' do
        subject.value('Order-Total Quantity').should == 838
      end
      it 'should return refecence number' do
        subject.value('REF').should == order.store.reference_number
      end
      it 'should return print charge' do
        subject.value('PRINT CHARGE').should == 37.71
      end
      it 'should return distribution charge' do
        subject.value('DISTRIBUTION CHARGE').should == 28.95
      end
    end
  end
end