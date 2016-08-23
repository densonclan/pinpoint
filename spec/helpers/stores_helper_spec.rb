# ./spec/models/address_spec.rb
require 'spec_helper'

describe StoresHelper do

  describe 'logo_url' do
  	specify { logo_url(Store.new(logo: 'ABC00', account_number: 'ABC00')).should == '/logos/ABC00.BMP' }
  end

  describe 'logo_path' do
  	specify { logo_path(Store.new(logo: 'ABC00', account_number: 'ABC00')).should == Rails.root.to_s + '/public/logos/ABC00.BMP' }
  end

  describe 'store_has_logo?' do
  	describe 'without logo attribute' do
	  	specify { store_has_logo?(Store.new).should be_false }
	  end
    describe 'without file' do
      before { File.should_receive(:exists?).with(Rails.root.to_s + '/public/logos/ABC00.PDF').and_return false }
      before { File.should_receive(:exists?).with(Rails.root.to_s + '/public/logos/ABC00.BMP').and_return false }
      specify { store_has_logo?(Store.new(logo: 'ABC00', account_number: 'ABC00')).should be_false }
    end
    describe 'with file' do
      before { File.should_receive(:exists?).with(Rails.root.to_s + '/public/logos/ABC00.PDF').and_return false }
      before { File.should_receive(:exists?).with(Rails.root.to_s + '/public/logos/ABC00.BMP').and_return true }
      specify { store_has_logo?(Store.new(logo: 'ABC00', account_number: 'ABC00')).should be_true }
    end
  end

  describe 'logo_image_tag' do
    before { @store = Store.new }
    describe 'with logo' do
      before do
        self.should_receive(:store_has_logo?).with(@store).and_return true
        self.should_receive(:logo_url).with(@store).twice.and_return '/path/to/logo.BMP'
      end
      specify { logo_image_tag(@store).should == image_tag('/path/to/logo.BMP') }
    end
    describe 'without logo' do
      before do
        self.should_receive(:store_has_logo?).with(@store).and_return false
        self.should_not_receive(:logo_url)
      end
      specify { logo_image_tag(@store).should be_nil }
    end
  end

  describe 'logo_updated_at' do
    before do
      @store = Store.new
      self.should_receive(:logo_path).with(@store).and_return '/path/to/logo.BMP'
      File.should_receive(:new).with('/path/to/logo.BMP').and_return double(mtime: Time.new(2013, 9, 26, 10, 20))
    end
    specify { logo_updated_at(@store).should == '26 Sep 13 at 10:20'}
  end
end