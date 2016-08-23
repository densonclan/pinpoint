require 'spec_helper'

describe PeriodImporter do

  before { @importer = PeriodImporter.new(@transport = Transport.new) }

  describe 'model_class' do
    specify { @importer.model_class.should == Period }
  end

  describe 'field_names' do
    specify { @importer.class.field_names.should == %w(period_number client week_number date_promo date_samples date_approval date_print date_dispatch current completed date_promo_end) }
  end

  describe 'set_extra_attributes' do
    describe 'with client' do
      before { @importer.should_receive(:set_client).with(@period = double('period'), 'xyz', 9) }
      specify { @importer.set_extra_attributes(@period, {'client' => 'xyz'}, 9).should be_nil }
    end
    describe 'without client' do
      before { @importer.should_receive(:set_client).with(@period = double('period'), nil, 9) }
      specify { @importer.set_extra_attributes(@period, {'clientx' => 'xyz'}, 9).should be_nil }
    end
  end
end