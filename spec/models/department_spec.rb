# ./spec/models/department_spec.rb
require 'spec_helper'

describe Department do
  before(:each) do
    @department = FactoryGirl.build(:department)
  end

  it 'should have valid factory' do
    @department.should be_valid
  end

  it 'should generate shortcode from the name' do
    @department.name = 'Test'
    @department.save!
    @department.short_code.should eq 'test'
  end

  it 'should not be valid without a name' do
    @department.name = nil
    @department.should_not be_valid
  end

  it 'should have a description no longer than 400 characters' do
    @department.description = (0...500).map{ ('a'..'z').to_a[rand(26)] }.join
    @department.should_not be_valid
  end

  it 'should have users' do
    @department.users.should_not be nil
  end

  it 'should unassign users when the it\'s destroyed' do
    @user = FactoryGirl.build(:user, :department => nil)
    @department.users << @user
    use = @department.users.first
    @department.destroy
    use.department.should be nil
  end
end