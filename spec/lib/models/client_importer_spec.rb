require 'spec_helper'

describe ClientImporter do

  before { @importer = ClientImporter.new(@transport = Transport.new) }

  describe 'model_class' do
    specify { @importer.model_class.should == Client }
  end

  describe 'field_names' do
    specify {  @importer.class.field_names.should == %w(name description code reference) }
  end
end