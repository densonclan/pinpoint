# ./spec/models/address_spec.rb
require 'spec_helper'

describe Transport do

  describe 'validations' do
    before do
      @transport = Transport.new transport_type: 'Address'
      @transport.spreadsheet_file_name = 'file.xls'
    end
    describe 'valid' do
      specify { @transport.should be_valid }
    end
    describe 'missing transport type' do
      before { @transport.transport_type = nil }
      specify { @transport.should_not be_valid }
    end
    describe 'invalid transport type' do
      before { @transport.transport_type = 'client' }
      specify { @transport.should_not be_valid }
    end
    describe 'missing spreadsheet_file_name' do
      before { @transport.spreadsheet_file_name = nil }
      specify { @transport.should_not be_valid }
    end
    describe 'default status' do
      before { @transport.valid? }
      specify { @transport.status.should == Transport::PENDING }
    end
  end

  describe 'pending_imports' do
    pending
  end

  describe 'run_pending_import' do
    before do
      Transport.should_receive(:pending_imports).and_return [@transport = double]
      @transport.should_receive(:process!)
    end
    specify { Transport.run_pending_imports.length.should == 1 }
  end

  describe 'process' do
    before { @transport = Transport.new(transport_type: 'Client') }
    describe 'with exception' do
      before do
        ClientImporter.should_receive(:new).with(@transport).and_return @importer = double('ClientImporter', valid?: true)
        @transport.should_receive(:importer_class).and_return ClientImporter
        @transport.should_receive(:working!)
        @importer.should_receive(:import!).and_raise @exception = StandardError.new('Oh sh!t')
        @transport.should_receive(:errored!)
        @transport.should_receive(:send_errored_email).with(@importer, @exception)
      end
      specify { @transport.process!.should be_nil }
    end
    describe 'without exception' do
      before do
        @transport.user = @user = User.new
        @transport.stub(:spreadsheet).and_return @spreadsheet = double
        ClientImporter.should_receive(:new).with(@transport).and_return @importer = double(:import! => true)
        @transport.should_receive(:working!)
      end
      describe 'when valid' do
        before do
          @transport.should_receive(:reload)
          @importer.should_receive(:valid?).and_return true
        end
        describe 'when cancelled' do
          before do
            @transport.should_receive(:cancelled?).and_return true
            @transport.should_not_receive(:send_email)
            @transport.should_not_receive(:complete!)
          end
          specify { @transport.process!.should be_nil }
        end
        describe 'when not cancelled' do
          before do
            @transport.should_receive(:cancelled?).and_return false
            @transport.should_receive(:send_email).with(@importer)
            @transport.should_receive(:complete!).and_return true
          end
          specify { @transport.process!.should be_true }
        end
      end
      describe 'when invalid' do
        before do
          @importer.should_receive(:valid?).and_return false
          @transport.should_receive(:invalid!)
          @transport.should_receive(:send_invalid_email).with(@importer)
        end
        specify { @transport.process!.should be_nil }
      end
    end
  end

  describe 'send_email' do
    before { ImportMailer.should_receive(:complete).with(@importer = double).and_return double(deliver: true) }
    specify { Transport.new.send_email(@importer).should be_true }
  end

  describe 'complete?' do
    before { @transport = Transport.new }
    describe 'false' do
      before { @transport.status = Transport::WORKING }
      specify { @transport.complete?.should be_false }
    end
    describe 'true' do
      before { @transport.status = Transport::COMPLETE }
      specify { @transport.complete?.should be_true }
    end
  end
end