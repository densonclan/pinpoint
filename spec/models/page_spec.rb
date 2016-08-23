# ./spec/models/page_spec.rb
require 'spec_helper'

describe Page do
  before(:each) do
    @page = FactoryGirl.build(:page)
  end

  it 'should have a valid factory' do
    @page.should be_valid
  end

  it 'should have a name' do
    @page.name = nil
    @page.should_not be_valid
  end

  it 'should have description no longer than 255 characters' do
    @page.description = (0...500).map{ ('a'..'z').to_a[rand(26)] }.join
    @page.should_not be_valid
  end

  it 'should have reference_number no longer than 32 characters' do
    @page.reference_number = (0...64).map{ ('a'..'z').to_a[rand(26)] }.join
    @page.should_not be_valid
  end
end