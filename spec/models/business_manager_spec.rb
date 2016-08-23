# ./spec/models/business_manager.rb
require 'spec_helper'

describe BusinessManager do
  describe 'validations' do
    before { @bm = BusinessManager.new name: 'Cosmo Kramer' }
    describe 'valid' do
      specify { @bm.should be_valid }
    end
    describe 'missing name' do
      before { @bm.name = nil }
      specify { @bm.should_not be_valid }
    end
    describe 'invalid email' do
      before { @bm.email = 'adasdsad' }
      specify { @bm.should_not be_valid }
    end
    describe 'valid email' do
      before { @bm.email = 'cosmo@cramerica-industries.com' }
      specify { @bm.should be_valid }
    end
  end
end