require 'spec_helper'

describe ExportTemplate do
  before(:each) do
  	@store = FactoryGirl.build(:export_template)
  end

  it 'should have a valid factory' do
  	@store.should be_valid
  end

  it 'should not be valid without a name' do
  	@store.name = nil
  	@store.should_not be_valid
  end

  it 'should not be valid without a value' do
  	@store.name = nil
  	@store.should_not be_valid
  end

  it 'should not be valid if the name is too long' do
  	@store.name = (0...200).map{ ('a'..'z').to_a[rand(26)] }.join
  	@store.should_not be_valid
  end

end
