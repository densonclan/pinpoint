require 'spec_helper'

describe PageImporter do

  before { @importer = PageImporter.new(@transport = Transport.new) }

  describe 'model_class' do
    specify { @importer.model_class.should == Page }
  end

  describe 'field_names' do
    specify { @importer.class.field_names.should == %w(name description reference_number) }
  end
end