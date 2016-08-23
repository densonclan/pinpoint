# ./spec/models/distributor_spec.rb
require 'spec_helper'

describe Distributor do
  before(:each) do
    @distributor = FactoryGirl.build(:royal_mail)
  end

  it 'should have a valid Factory' do
    @distributor.should be_valid
  end

  it 'should not be valid without a name' do
    @distributor.name = nil
    @distributor.should_not be_valid
  end

  it 'should not be valid without a type' do
    @distributor.distributor_type = nil
    @distributor.should_not be_valid
  end

  it 'should have a valid description' do
    @distributor.description = (0...20000).map{ ('a'..'z').to_a[rand(26)] }.join
    @distributor.should_not be_valid
  end

  it 'should have a valid reference_number' do
    @distributor.reference_number = (0...300).map{ ('a'..'z').to_a[rand(26)] }.join
    @distributor.should_not be_valid
  end
end