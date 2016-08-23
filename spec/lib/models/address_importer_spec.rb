require 'spec_helper'

describe AddressImporter do

  before { @importer = AddressImporter.new(@transport = Transport.new) }
  describe 'model_class' do
    specify { @importer.model_class.should == Address }
  end

  describe 'field_names' do
    specify { @importer.class.field_names.should == %w(title full_name first_line second_line third_line city postcode county phone_number email address_type business_name) }
  end
end