# ./spec/models/address_spec.rb
require 'spec_helper'

describe StorePdfHelper do

# def convert_to_jpg(source, destination)
#     thumb = Magick::Image.read(source).first
#     thumb.resize_to_fit!(350)
#     thumb.format = "JPG"
#     thumb.write(destination)
#   end

  describe 'convert_to_jpg' do
    describe 'actually' do
      before(:all) do
        source = Rails.root.join('spec', 'files', 'Z2312.BMP')
        @destination = Rails.root.join('spec', 'files', 'Z2312.jpg')
        convert_to_jpg(source, @destination)
        @thumb = Magick::Image.read(@destination).first
      end
      after(:all) do
        File.delete @destination
      end
      specify { @thumb.format.should == 'JPEG' }
      specify { @thumb.columns.should == 350 }
    end
    describe 'theoretically' do
      before do
        Magick::Image.should_receive(:read).with('/path/to/bmp').and_return double(first: thumb = double('Thumb'))
        thumb.should_receive(:resize_to_fit!).with(350)
        thumb.should_receive(:format=).with('JPG')
        thumb.should_receive(:write).with('/path/to/jpg')
      end
      specify { convert_to_jpg('/path/to/bmp', '/path/to/jpg').should be_nil }
    end
  end

  describe 'logo_jpg_path' do
    specify { logo_jpg_path(double('Store', logo: 'XYZ123')).to_s.should == "#{Rails.root.to_s}/public/logos/XYZ123.jpg" }
  end

  describe 'store_jpg_logo' do
    before { self.should_receive(:logo_jpg_path).with(@store = double('Store')).and_return @jpg = double('JPG') }
    describe 'when jpg exists' do
      before do
        File.should_receive(:exists?).with(@jpg).and_return true
        self.should_not_receive(:convert_to_jpg)
      end
      specify { store_jpg_logo(@store).should == @jpg }
    end
    describe 'when jpg doesnt exist' do
      before do
        File.should_receive(:exists?).with(@jpg).and_return false
        self.should_receive(:logo_path).with(@store).and_return logo = double('Logo')
        self.should_receive(:convert_to_jpg).with(logo, @jpg)
      end
      specify { store_jpg_logo(@store).should == @jpg }
    end
  end
end