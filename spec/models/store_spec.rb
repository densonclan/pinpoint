# ./spec/models/store_spec.rb
require 'spec_helper'

describe Store do

  describe 'the new way' do
    describe 'new with user' do
      describe 'as internal' do
        before do
          @user = User.new(user_type: User::DISTRIBUTION, client_id: 123)
          @store = Store.new_with_user({account_number: 'XYZ', client_id: 999}, @user)
        end
        specify { @store.account_number.should == 'XYZ' }
        specify { @store.user.should == @user }
        specify { @store.client_id.should == 999 }
        specify { @store.updated_by.should == @user }
      end
      describe 'as client' do
        before do
          @user = User.new(user_type: User::CLIENT, client_id: 321)
          @store = Store.new_with_user({account_number: 'ZYX', client_id: 666}, @user)
        end
        specify { @store.account_number.should == 'ZYX' }
        specify { @store.user.should == @user }
        specify { @store.client_id.should == 321 }
        specify { @store.updated_by.should == @user }
      end
    end

    describe 'for_county' do
      before do
        @store1 = create_a(:store, address: create_a(:address, address_type: Address::STORE, county: 'Northamptonshire'))
        @store2 = create_a(:store, address: create_a(:address, address_type: Address::STORE, county: 'Northampton'))
      end
      specify { Store.for_county('Northamptonshire').should == [@store1]}
      specify { Store.for_county(nil).should == [@store1, @store2]}
    end

    describe 'search' do
      before :all do
        @s1 = create_a(:just_store, account_number: 'A234567', owner_name: 'Paul Smith')
        @s2 = create_a(:just_store, reference_number: 'A234567', owner_name: 'Paul Smith')
        @s3 = create_a(:just_store, reference_number: 'xyz999', owner_name: 'Paul Smith')
        @s4 = create_a(:just_store, description: 'heres some text', owner_name: 'Paul Smith')
        @s5 = create_a(:just_store, owner_name: 'Paul Smith', business_manager: FactoryGirl.create(:business_manager, name: 'Joe Priestley'))
        @s6 = create_a(:just_store, owner_name: 'Paul Smith', client: FactoryGirl.create(:client, name: 'Cando Attitude'))
        @s7 = create_a(:just_store, owner_name: 'Paul Smith', postcode: 'NE1 3ZZ')
        @s8 = create_a(:just_store, owner_name: 'Paul Brown')
      end

      after :all do
        delete_all %w(stores business_managers clients)
      end

      specify { Store.search('567').should include(@s1, @s2) }
      specify { Store.search('567').count.should == 2 }
      specify { Store.search('a234').should include(@s1, @s2) }
      specify { Store.search('a234').count.should == 2 }
      specify { Store.search('XYZ').should == [@s3] }
      specify { Store.search('some text').should == [@s4] }
      specify { Store.search('Joe ').should == [@s5] }
      specify { Store.search('cando attitude').should == [] }
      specify { Store.search('NE1 3zz').should == [@s7] }
      specify { Store.search('brown').should == [@s8] }
      specify { Store.search('e').map {|s| s.account_number}.sort.should == [@s4.account_number, @s5.account_number, @s7.account_number].sort }
    end

    describe 'find_others' do
      before do
        @client1 = FactoryGirl.create(:client)
        @client2 = FactoryGirl.create(:client)

        @s = FactoryGirl.build(:just_store, owner_name: 'Jessie', client: @client1)
        @s.save(validate: false)
        @s1 = FactoryGirl.build(:just_store, owner_name: 'Jessie', client: @client1)
        @s1.save(validate: false)
        @s2 = FactoryGirl.build(:just_store, owner_name: 'Jessie', client: @client2)
        @s2.save(validate: false)
        @s3 = FactoryGirl.build(:just_store, owner_name: 'Jessie', client: @client1)
        @s3.save(validate: false)
        @s4 = FactoryGirl.build(:just_store, owner_name: 'jessie', client: @client1)
        @s4.save(validate: false)
      end
      specify { @s.find_others.map {|s| s.account_number}.sort.should == [@s1.account_number, @s3.account_number].sort }
    end
  end

  describe 'reset_personalised_panel' do
    it 'resets personalised panel fields' do
      store = FactoryGirl.create(:store, personalised_panel_1: true)
      Store.reset_personalised_panel
      store.reload.personalised_panel_1.should_not be
    end
  end

  describe 'with store' do
    before { @store = Store.new(account_number: 'X50909', reference_number: 'ABC987', owner_name: 'Sanjay Gupta', client_id: 1) }

    describe 'validations' do
      describe 'valid' do
        specify { @store.should be_valid }
      end
      describe 'lowercase account number' do
        before { @store.account_number = 'x50909' }
        specify { @store.should_not be_valid }
      end
      describe 'short account number' do
        before { @store.account_number = 'X5090' }
        specify { @store.should be_valid }
      end
      describe 'long account number' do
        before { @store.account_number = 'X1234567' }
        specify { @store.should be_valid }
      end
      describe 'mixed account number' do
        before { @store.account_number = 'X123V4' }
        specify { @store.should be_valid }
      end
      describe 'mixed account number - starting with number' do
        before { @store.account_number = '3X12344' }
        specify { @store.should be_valid }
      end
      describe 'reference number too long' do
        before { @store.reference_number = '12345678901234567890123456789012x' }
        specify { @store.should_not be_valid }
      end
    end

    describe 'generate account number' do
      pending
    end

    describe 'clean logo' do
      before do 
        @store.logo = 'Z23423.BMP'
        @store.valid?
      end
      specify { @store.logo.should == 'Z23423' }
    end

    describe 'set preferred distribution' do
      before { @store.valid? }
      specify { @store.preferred_distribution.should == 'Store Delivery'}

    describe 'set reference number from account number' do
      before do
        @store.reference_number = nil
        @store.valid?
      end
      specify { @store.reference_number.should == 'X50909' }
    end    
  end

  describe 'having_personalised_panel' do
    let!(:store_with_personalised_panel) { FactoryGirl.create(:store, personalised_panel_1: true) }
    let!(:store_without_personalised_panel) { FactoryGirl.create(:store, personalised_panel_1: false) }

    it 'returns stores having personalised panel' do
      Store.having_personalised_panel.should eq([store_with_personalised_panel])
    end
  end

  describe 'having_generic_panel' do
    let!(:store_with_generic_panel) { FactoryGirl.create(:store, personalised_panel_1: false) }
    let!(:store_without_generic_panel) { FactoryGirl.create(:store, personalised_panel_1: true, personalised_panel_2: true, personalised_panel_3: true) }

    it 'returns stores having personalised panel' do
      Store.having_generic_panel.should eq([store_with_generic_panel])
    end
  end

  describe 'set store name' do
    before do
      @store = FactoryGirl.create(:store)
      @store.address = FactoryGirl.create(:address, address_type: Address::STORE, full_name: 'Samual L Jackson', postcode: '8BB 2XX', updated_by: FactoryGirl.create(:user))
      @store.override_lock = true
      @store.save
      @store.reload
    end
    specify { @store.owner_name.should == 'Samual L Jackson' }
    specify { @store.postcode.should == '8BB 2XX' }
  end

  it 'should generate an account number for a given Client when created' do
    @client = FactoryGirl.create(:client)
    @store = FactoryGirl.create(:store, :account_number => 'A08909', :client_id => @client .id)
    @new_store = FactoryGirl.create(:store, :account_number => nil, :client_id => @client .id)
    @new_store.account_number.should eq('A08910')
  end

  describe 'store_address' do
    before do
      @store = Store.new
      @store.address = @store_address = FactoryGirl.build(:address, address_type: 'store')
    end
    specify { @store.store_address.should == @store_address }
  end
end

end