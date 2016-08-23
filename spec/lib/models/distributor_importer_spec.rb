require 'spec_helper'

describe DistributorImporter do

  before { @importer = DistributorImporter.new(@transport = Transport.new) }
  describe 'model_class' do
    specify { @importer.model_class.should == Distributor }
  end

  describe 'field_names' do
    specify { @importer.class.field_names.should == %w(name distributor_type description reference_number) }
  end
end