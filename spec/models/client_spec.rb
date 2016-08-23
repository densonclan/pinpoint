# ./spec/models/client_spec.rb
require 'spec_helper'

describe Client do
  before(:each) do
    @client = FactoryGirl.build(:client)
  end

  it 'should not be valid without a name' do
    @client.name = nil
    @client.should_not be_valid
  end

  it 'should not be valid without a reference' do
    @client.reference = nil
    @client.should_not be_valid
  end

  it 'should not be valid without a code' do
    @client.code = nil
    @client.should_not be_valid
  end

  it 'should have description no longer than 400 characters' do
    @client.description = (0...500).map{ ('a'..'z').to_a[rand(26)] }.join
    @client.should_not be_valid
  end
end