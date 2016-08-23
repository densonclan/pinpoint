require 'spec_helper'

describe 'AddressManager' do
  let(:user) { User.new }
  let(:distribution) do
    distribution = Distribution.new
    distribution.should_receive :save
    distribution
  end

  let(:address) do
    a = Address.new
    a.should_receive(:save).and_return true
    a.stub(:id).and_return 17
    a
  end
  
  before { @manager = AddressManager.new(user) }

  describe 'create' do
    before do
      a = address
      Address.should_receive(:new).and_return a
      Distribution.should_receive(:find).with(6).and_return distribution
      @address = @manager.create({first_line: 'test', distribution_id: 6})
    end
    specify { @address.updated_by.should == user }
    specify { @address.first_line.should == 'test' }
    specify { distribution.address_id.should == 17 }
  end

  describe 'update' do

    before do
      Address.should_receive(:accessible_by).with(user).and_return address
      address.should_receive(:find).with(17).and_return address
      Distribution.should_receive(:find).with(6).and_return distribution
      @address = @manager.update(17, {first_line: 'test', distribution_id: 6})
    end
    specify { @address.updated_by.should == user }
    specify { @address.first_line.should == 'test' }
    specify { distribution.address_id.should == 17 }
  end
end