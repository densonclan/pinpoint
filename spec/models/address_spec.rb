# ./spec/models/address_spec.rb
require 'spec_helper'

describe Address do

  before { @address = Address.new full_name: 'Jon Doe' }

  describe 'validations' do
    describe 'valid' do
      specify { @address.should be_valid }
    end
    describe 'requires name' do
      before { @address.full_name = '' }
      specify { @address.should_not be_valid }
    end

    describe 'email address' do
      describe 'invalid' do
        before { @address.email = 'asdfasdf' }
        specify {  @address.should_not be_valid }
      end
      describe 'valid' do
        before { @address.email = 'joe-d.smith23_son@some.place.school.au' }
        specify { @address.should be_valid }
      end
    end
  end

  describe 'set name from business' do
    before do
      @address.attributes = {full_name: nil, business_name: 'MATE Ltd.'}
      @address.valid?
    end
    specify { @address.full_name.should == 'MATE Ltd.' }
  end

  describe 'address type' do
    before { @address = Address.new }
    describe 'store?' do
      before { @address.address_type = Address::STORE }
      specify { @address.store?.should be_true }
    end
  end

  describe 'search' do
    before :all do
      @a1 = FactoryGirl.create(:address, address_type: 'store')
      @a2 = FactoryGirl.create(:address, address_type: 'store', business_name: 'ABC')
      @a3 = FactoryGirl.create(:address, address_type: 'solus', full_name: 'XYZ')
      @a4 = FactoryGirl.create(:address, address_type: 'solus', county: 'avon')
      @a5 = FactoryGirl.create(:address, address_type: 'newspaper', city: 'London')
      @a6 = FactoryGirl.create(:address, address_type: 'newspaper', postcode: 'NW1 8DD')
      @a7 = FactoryGirl.create(:address, address_type: 'newspaper', first_line: '83 Fitzsimmons Place')
      @a8 = FactoryGirl.create(:address, address_type: 'newspaper', second_line: 'West Croydon')
    end

    after :all do
      delete_all ['addresses']
    end

    specify { Address.search('xyz').should == [@a3] }
    specify { Address.search('avon').should == [@a4] }
    specify { Address.search('VON').should == [@a4] }
    specify { Address.search('LONDON').should == [@a5] }
    specify { Address.search('8DD').should == [@a6] }
    specify { Address.search('NW1 ').should == [@a6] }
    specify { Address.search('fitzsimmons').should == [@a7] }
    specify { Address.search('West croydon').should == [@a8] }
  end
end