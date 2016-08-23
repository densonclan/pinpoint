require 'spec_helper'

describe StoreImporter do

  before { @importer = StoreImporter.new(@transport = Transport.new) }

  describe 'model_class' do
    specify { @importer.model_class.should == Store }
  end

  describe 'field_names' do
    specify { @importer.class.field_names.should ==  %w(account_number reference_number preferred_distribution client business_manager logo participation_only preferred_option full_name first_line second_line third_line city postcode county phone_number email) }
  end

  describe 'find_or_create_object' do
    describe 'existing store' do
      before { Store.should_receive(:find_by_account_number).with('A012345').and_return @store = double }
      specify { @importer.find_or_create_object({'account_number' => 'A012345'}).should == @store }
    end
    describe 'new store' do
      before do
        Store.should_receive(:find_by_account_number).with('A012345').and_return nil
        Store.should_receive(:new_with_user).with(nil, @user).and_return @store = double
      end
      specify { @importer.find_or_create_object({'account_number' => 'A012345'}) }
    end
  end

  describe 'set_extra_attributes' do
    before do
      @row = {'client' => 'xyz', 'business_manager' => 'tbh', 'preferred_option' => 'D'}
    end
    describe 'with invalid client' do
      before do
        @importer.should_receive(:set_client).with(@store = double(client_id: nil), 'xyz', 9)
        @importer.should_not_receive(:set_address)
      end
      specify { @importer.set_extra_attributes(@store, @row, 9).should be_nil }
    end
    describe 'with valid client' do
      before do
        @importer.should_receive(:set_client).with(@store = Store.new(client_id: 2, owner_name: nil), 'xyz', 9)
        @importer.should_receive(:set_address).with(@store, @row)
        @importer.should_receive(:set_all_comments).with(@store, @row)
        @importer.should_receive(:set_business_manager).with(@store, 'tbh', 9)
        @importer.should_receive(:set_preferred_option).with(@store, 'D', 9)
        @importer.set_extra_attributes(@store, @row, 9)
      end
      specify { @store.owner_name.should == 'unknown' }
    end
  end

  describe 'set_preferred_option' do
    before { @store = Store.new }
    describe 'when blank' do
      before { @store.should_not_receive(:preferred_option=) }
      specify { @importer.set_preferred_option(@store, '', 99).should be_nil }
    end
    describe 'when invalid' do
      before do
        @store.stub(:client).and_return(double('Client', id: 12, name: 'Costcutter'))
        Option.should_receive(:for_client).with(12).and_return option = double('Option')
        option.should_receive(:named).with('D').and_return(option)
        option.should_receive(:first).and_return nil
        @importer.should_receive(:save_error).with(99, "Unrecognised option 'D' for Costcutter.")
      end
      specify { @importer.set_preferred_option(@store, 'D', 99).should be_nil }
    end
    describe 'when valid' do
      before do
        @store.stub(:client).and_return(double('Client', id: 12, name: 'Costcutter'))
        Option.should_receive(:for_client).with(12).and_return @option = Option.new
        @option.should_receive(:named).with('D').and_return(@option)
        @option.should_receive(:first).and_return @option
        @importer.should_not_receive(:save_error)
        @importer.set_preferred_option(@store, 'D', 99)
      end
      specify { @store.preferred_option.should == @option }
    end
  end

  describe 'set_all_comments' do
    before do
      @store = double
      @importer.should_receive(:set_comment).with(@store, 'A comment here')
      @importer.should_receive(:set_comment).with(@store, '')
    end
    specify { @importer.set_all_comments(@store, {'important_comment' => '', 'icomment' => 'A comment here', 'not_commnt' => 'blah'}).length.should == 2 }
  end

  describe 'set_comment' do
    before do
      @store = Store.new
      comment = @store.comments.build(full_text: 'something good here')
      comment.user = @comment_user = User.new
    end
    describe 'if comment is blank' do
      before { @importer.set_comment(@store, '') }
      specify { @store.comments.length.should == 1 }
      specify { @store.comments.first.full_text.should == 'something good here' }
    end
    describe 'if comment exists' do
      before { @importer.set_comment(@store, 'something good here') }
      specify { @store.comments.length.should == 1 }
      specify { @store.comments.first.user.should == @comment_user }
    end
    describe 'new comment' do
      before { @importer.set_comment(@store, 'new comment') }
      specify { @store.comments.length.should == 2 }
      specify { @store.comments.first.user.should == @comment_user }
      specify { @store.comments.first.full_text.should == 'something good here' }
      specify { @store.comments.last.user.should == @user }
      specify { @store.comments.last.full_text.should == 'new comment' }
    end
  end

  describe 'find_or_build_address' do
    before { @store = Store.new }
    describe 'existing' do
      before { @store.address = @address = Address.new }
      specify { @importer.find_or_build_address(@store).should == @address }
    end
    describe 'new' do
      specify { @importer.find_or_build_address(@store).should be_new_record }
      specify { @importer.find_or_build_address(@store).address_type.should == Address::STORE }
    end
  end

  describe 'set_address' do
    describe 'missing name' do
      before { @importer.should_not_receive :find_or_build_address }
      specify { @importer.set_address double, {'full_name' => '', 'first_line' => '89 Waterloo Place'} }
    end
    describe 'sets fields' do
      before do
        @importer.should_receive(:find_or_build_address).with(@store = double).and_return @address = Address.new
        @importer.set_address @store, {'delivery_postcode' => 'EC2A 3BF', 'full_name' => 'Frank Costanza', 'first_line' => '89 Waterloo Place'}
      end
      specify { @address.full_name.should == 'Frank Costanza' }
      specify { @address.first_line.should == '89 Waterloo Place' }
      specify { @address.postcode.should be_blank }
    end
  end

  describe 'set_client' do
    before { @store = Store.new }
    describe 'when blank' do
      before do
        @importer.should_receive(:save_error).with(9, 'Client name missing')
        @importer.set_client(@store, '', 9)
      end
      specify { @store.client.should be_nil }
    end
    describe 'with valid name' do
      before do
        @client = create_a(:client, name: 'NISA')
        @importer.should_not_receive(:save_error)
        @importer.set_client(@store = Store.new, 'NISA', 9)
      end
      specify { @store.client.should == @client }
    end
    describe 'with invalid name' do
      before do
        @importer.should_receive(:save_error).with(9, "Invalid client 'NIISA'")
        @importer.set_client(@store, 'NIISA', 9)
      end
      specify { @store.client.should be_nil }
    end
  end

  describe 'set_business_manager' do
    describe 'when blank' do
      before do
        @importer.should_not_receive(:save_error)
        @importer.set_business_manager(@store = Store.new, '', 9)
      end
      specify { @store.business_manager.should be_nil }
    end
    describe 'with valid name' do
      before do
        BusinessManager.should_receive(:for_client).with(12).and_return @bm = BusinessManager.new
        @bm.should_receive(:find_by_name_case_insensitive).with('Jason Alexander').and_return @bm
        @importer.should_not_receive(:save_error)
        @store = Store.new(client_id: 12)
        @importer.set_business_manager(@store, 'Jason Alexander', 9)
      end
      specify { @store.business_manager.should == @bm }
    end
    describe 'with invalid name' do
      before do
        BusinessManager.should_receive(:for_client).with(12).and_return @bm = double
        @bm.should_receive(:find_by_name_case_insensitive).with('Jason Alexander').and_return nil
        @importer.should_not_receive(:save_error)
        @store = Store.new(client_id: 12)
        @store.stub(:client).and_return Client.new(name: 'NISA')
        @importer.set_business_manager(@store, 'Jason Alexander', 9)
      end
      specify { @store.business_manager.should be_new_record }
      specify { @store.business_manager.client_id.should == 12 }
      specify { @store.business_manager.name.should == 'Jason Alexander' }
    end
  end
end