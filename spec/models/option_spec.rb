# ./spec/models/option_spec.rb
require 'spec_helper'

describe Option do
  describe 'validations' do
    before do
      @option = Option.new name: 'SG - Nisa', price_zone: 'Convenience'
      @option.client = Client.new      
    end
    describe 'valid' do
      specify { @option.should be_valid }
    end
    describe 'missing name' do
      before { @option.name = '' }
      specify { @option.should_not be_valid }
    end
    describe 'missing price zone' do
      before { @option.price_zone = '' }
      specify { @option.should_not be_valid }
    end
    describe 'missing client' do
      before { @option.client = nil }
      specify { @option.should_not be_valid }
    end
    describe 'long description' do
      before { @option.description = 256.times.map {'a'} }
      specify { @option.should_not be_valid }
    end
    describe 'long reference' do
      before { @option.reference_number = 256.times.map {'a'} }
      specify { @option.should_not be_valid }
    end
  end
end