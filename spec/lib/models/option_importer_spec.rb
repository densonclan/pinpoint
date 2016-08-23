require 'spec_helper'

describe OptionImporter do

  before { @importer = OptionImporter.new(@transport = Transport.new) }
  describe 'model_class' do
    specify { @importer.model_class.should == Option }
  end

  describe 'field_names' do
    specify { @importer.class.field_names.should == %w(name description box_quantity price_zone multibuy licenced total_ambient total_licenced total_temp total_quantity reference_number client page) }
  end

  describe 'set_extra_attributes' do
    before do
      @importer.should_receive(:set_client).with(@option = double('Option'), 'xyz', 9)
      @importer.should_receive(:set_page).with(@option, 'fdg', 9)
    end
    specify { @importer.set_extra_attributes(@option, {'page' => 'fdg', 'client' => 'xyz'}, 9).should be_nil }
  end

  describe 'set_page' do
    describe 'with blank page' do
      before do
        Page.should_not_receive(:where)
        @importer.should_not_receive(:save_error)
      end
      specify { @importer.set_page(double('Option'), '', 2).should be_nil }
    end
    describe 'with valid page name' do
      before do
        @importer.should_not_receive(:save_error)
        Page.should_receive(:where).with('name=? OR reference_number=?', 'XYZ', 'XYZ').and_return(double(first: @page = Page.new))
        @option = Option.new
        @option.client = Client.new
        @option.client.should_receive(:current_period).and_return Period.new(current: true)
        @importer.set_page(@option, 'XYZ', 2)
      end
      specify { @option.page.should == @page }
    end
    describe 'with invalid page name' do
      before do
        @importer.should_receive(:save_error).with(2, "Unrecognised page name 'XYZ'. Valid values are: ABC")
        Page.should_receive(:where).with('name=? OR reference_number=?', 'XYZ', 'XYZ').and_return double(first: nil)
        @importer.should_receive(:page_options).and_return 'ABC'
        @option = Option.new
        @option.client = Client.new
        @importer.set_page(@option, 'XYZ', 2)
      end
      specify { @option.page.should be_nil }
    end
  end
end