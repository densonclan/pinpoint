# ./spec/models/document_spec.rb
require 'spec_helper'

describe Document do

  describe 'the old way' do
    before(:each) do
      @document = FactoryGirl.build(:document)
    end

    it 'should not be valid without a title' do
      @document.title = nil
      @document.should_not be_valid
    end

    it 'should not be valid if tke description is over 400 characters' do
      @document.description = (0...500).map{ ('a'..'z').to_a[rand(26)] }.join
      @document.should_not be_valid
    end

    it { should belong_to(:store) }

    it { should belong_to(:user) }

    it { should have_attached_file(:file) }
  end

  describe 'accessible_by' do
    before(:all) do
      @client = create_a(:client)
      @user1 = create_a(:just_user, client: @client, user_type: User::READ_ONLY)
      @user2 = create_a(:just_user, client: @client, user_type: User::READ_ONLY)
      @user3 = create_a(:just_user, client: create_a(:client), user_type: User::CLIENT)
      @internal = create_a(:just_user, client: create_a(:client), user_type: User::DISTRIBUTION)
      @doc1 = create_a(:document, user: @user1)
      @doc2 = create_a(:document, user: @user2)
      @doc3 = create_a(:document, user: @user3)
      @doc4 = create_a(:document, user: @internal)
    end
    after(:all) do
      delete_all %w(clients users documents)
    end
    specify { Document.accessible_by(@user1).map {|d| d.id}.sort.should == [@doc1.id, @doc2.id].sort }
    specify { Document.accessible_by(@user2).map {|d| d.id}.sort.should == [@doc1.id, @doc2.id].sort }
    specify { Document.accessible_by(@user3).sort.should == [@doc3] }
    specify { Document.accessible_by(@internal).map {|d| d.id}.sort.should == [@doc1.id, @doc2.id, @doc3.id, @doc4.id].sort }
  end

  describe 'search' do
    before(:all) do
      @store1 = create_a(:just_store, owner_name: 'Frank Costanza')
      @store2 = create_a(:just_store, account_number: 'FB0234345')
      @doc1 = create_a(:document, title: 'Terms and Conditions', store: @store1, description: 'READ THIS!')
      @doc2 = create_a(:document, description: 'Here is a great read', store: @store1)
      @doc3 = create_a(:document, description: 'Here is a great read', store: @store2)
    end
    after(:all) do
      delete_all %w(stores documents)
    end
    specify { Document.search('Costanza').map {|d| d.id}.sort.should == [@doc1.id, @doc2.id].sort }
    specify { Document.search('fb023').map {|d| d.id}.sort.should == [@doc3.id].sort }
    specify { Document.search('Read').map {|d| d.id}.sort.should == [@doc1.id, @doc2.id, @doc3.id].sort }
    specify { Document.search('AND').map {|d| d.id}.sort.should == [@doc1.id].sort }
  end

  describe 'set store from account number' do
    describe 'without store' do
      before do
        @store = create_a(:just_store, account_number: '12345')
        @doc = Document.new(account_number: '12345')
        @doc.valid?
      end
      specify { @doc.store.should == @store }
    end
    describe 'with store' do
      before do
        @doc = Document.new(account_number: '12345')
        @doc.store = @existing = create_a(:just_store)
        @doc.valid?
      end
      specify { @doc.store.should == @existing }
    end
  end
end