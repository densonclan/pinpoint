require 'spec_helper'

describe BusinessManagerImporter do

  before { @importer = BusinessManagerImporter.new(@transport = Transport.new) }
  describe 'model_class' do
    specify { @importer.model_class.should == BusinessManager }
  end

  describe 'field_names' do
    specify { @importer.class.field_names.should == %w(name email additional_info phone_number) }
  end

  describe 'set_extra_attributes' do
    before do
      @row = {'client' => 'James Gandolfini', 'ignored' => 'something else'}
      @importer.should_receive(:set_client).with(@bm = BusinessManager.new, 'James Gandolfini', 9)
    end
    specify { @importer.set_extra_attributes(@bm, @row, 9 ).should be_nil }
  end
end