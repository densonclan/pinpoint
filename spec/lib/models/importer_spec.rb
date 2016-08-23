require 'spec_helper'

describe Importer do

  describe 'field_names_as_csv' do
    before { Importer.should_receive(:field_names).and_return %w(name reference_number client post_code) }
    specify { Importer.field_names_as_csv.should == 'Name,Reference Number,Client,Post Code' }
  end

  describe 'headers' do
    before do
      @importer = Importer.new(@transport = Transport.new)
      spreadsheet = double
      spreadsheet.should_receive(:row).with(1).and_return ['One Two', 'Three', 'F F S', nil]
      @importer.stub(:spreadsheet).and_return(spreadsheet)
    end
    specify { @importer.headers.should == ['one_two', 'three', 'f_f_s', ''] }
  end

  describe 'import!' do
    before do
      @transport = Transport.new
      @transport.stub(:reload).and_return @transport
      @importer = Importer.new(@transport)
      spreadsheet = double()
      spreadsheet.stub(:last_row).and_return(4)
      spreadsheet.should_receive(:row).with(2).and_return ['a', 'b', 'c']
      spreadsheet.should_receive(:row).with(3).and_return ['d', 'e', 'f']
      spreadsheet.should_receive(:row).with(4).and_return ['g', 'h', 'i']
      @importer.stub(:spreadsheet).and_return spreadsheet
      @importer.should_receive(:headers).exactly(3).times.and_return %w(x y z)
      @importer.should_receive(:process_row).with({'x' => 'a', 'y' => 'b', 'z' => 'c'}, 2)
      @importer.should_receive(:process_row).with({'x' => 'd', 'y' => 'e', 'z' => 'f'}, 3)
      @importer.should_receive(:process_row).with({'x' => 'g', 'y' => 'h', 'z' => 'i'}, 4)
    end
    specify { @importer.import!.should == (2..4) }
  end

  describe 'valid?' do
    before { @importer = Importer.new(Transport.new) }
    describe 'true' do
      before { @importer.should_receive(:invalid_headers).and_return [] }
      specify { @importer.valid?.should be_true }
    end
    describe 'false' do
      before { @importer.should_receive(:invalid_headers).and_return ['one', 'two'] }
      specify { @importer.valid?.should be_false }
    end
  end

  describe 'invalid_headers' do
    before do
      @importer = OrderImporter.new(Transport.new)
      @importer.should_receive(:headers).and_return ['invalid 1', 'account_number', '', 'status', 'invalid 2']
    end
    specify { @importer.invalid_headers.should == ['invalid 1', 'invalid 2'] }
  end

  describe 'process_row' do
    before do
      @importer = Importer.new(@transport = Transport.new)
      Client.should_receive(:accessible_attributes).and_return %w(name description reference code)
    end
    describe 'with existing object' do
      before do
        @importer.stub(:model_class).and_return Client
        Client.should_receive(:find_by_id).with('12').and_return @client = Client.new
        @row = {'id' => '12', 'name' => 'Test', 'description' => 'Yes Hello', 'code' => 'ABC'}
        @importer.should_receive(:set_extra_attributes).with(@client, @row, 9)
      end
      describe 'saved successfully' do
        before do
          @client.should_receive(:save).and_return(true)
          @importer.should_not_receive(:log_errors)
          @importer.process_row @row, 9
        end
        specify { @client.attributes.slice(*['name', 'description', 'code', 'reference']).should == {'name' => 'Test', 'description' => 'Yes Hello', 'code' => 'ABC', 'reference' => nil} }
        specify { @importer.success_count.should == 1 }
      end
      describe 'not saved successfully' do
        before do
          @client.should_receive(:save).and_return(false)
          @importer.should_receive(:log_errors).with(@client, 9)
          @importer.process_row @row, 9
        end
        specify { @client.attributes.slice(*['name', 'description', 'code', 'reference']).should == {'name' => 'Test', 'description' => 'Yes Hello', 'code' => 'ABC', 'reference' => nil} }
        specify { @importer.success_count.should == 0 }
      end
    end

    describe 'with new object' do
      before do
        @importer.stub(:model_class).and_return Client
        Client.should_receive(:find_by_id).with(nil).and_return nil
        @client = Client.new
        Client.should_receive(:new).and_return @client
        @row = {'name' => 'Test', 'description' => 'Yes Hello', 'code' => 'ABC'}
        @importer.should_receive(:set_extra_attributes).with(@client, @row, 9)
      end
      describe 'saved successfully' do
        before do
          @client.should_receive(:save).and_return(true)
          @importer.should_not_receive(:log_errors)
          @importer.process_row @row, 9
        end
        specify { @client.attributes.slice(*['name', 'description', 'code', 'reference']).should == {'name' => 'Test', 'description' => 'Yes Hello', 'code' => 'ABC', 'reference' => nil} }
        specify { @importer.success_count.should == 1 }
      end
      describe 'not saved successfully' do
        before do
          @client.should_receive(:save).and_return(false)
          @importer.should_receive(:log_errors).with(@client, 9)
          @importer.process_row @row, 9
        end
        specify { @client.attributes.slice(*['name', 'description', 'code', 'reference']).should == {'name' => 'Test', 'description' => 'Yes Hello', 'code' => 'ABC', 'reference' => nil} }
        specify { @importer.success_count.should == 0 }
      end
    end
  end

  describe 'set_client' do
    before { @importer = Importer.new(@transport = Transport.new) }
    describe 'when blank' do
      before do
        @importer.should_receive(:save_error).with(9, 'Client name missing')
        @importer.set_client(@bm = BusinessManager.new, '', 9)
      end
      specify { @bm.client.should be_nil }
    end
    describe 'with valid name' do
      before do
        Client.should_receive(:lookup).with('NISA').and_return @client = Client.new
        @importer.should_not_receive(:save_error)
        @importer.set_client(@bm = BusinessManager.new, 'NISA', 9)
      end
      specify { @bm.client.should == @client }
    end
    describe 'with invalid name' do
      before do
        Client.should_receive(:lookup).with('NISA').and_return nil
        @importer.should_receive(:save_error).with(9, "Invalid client name 'NISA'")
        @importer.set_client(@bm = BusinessManager.new, 'NISA', 9)
      end
      specify { @bm.client.should be_nil }
    end
  end

  describe 'open_spreadsheet' do
    before do
      @transport = Transport.new
      @transport.should_receive(:spreadsheet).and_return double('Spreadsheet', path: '/some/where/good.csv')
      @importer = Importer.new(@transport)
      Roo::Spreadsheet.should_receive(:open).with('/some/where/good.csv', {:csv_options=>{:encoding=>"ISO-8859-1"}}).and_return 'ok'
    end
    specify { @importer.open_spreadsheet.should == 'ok' }
  end

  describe 'log_errors' do
    before do
      @subject = double(errors: double(to_a: ['Name is invalid', 'Something else is wrong']))
      @importer = Importer.new(@transport = Transport.new)
      @importer.stub(:name).and_return('Client')
      @importer.should_receive(:save_error).with(9, 'Name is invalid, Something else is wrong')
    end
    specify { @importer.log_errors(@subject, 9).should be_nil }
  end

  describe 'save_errors' do
    before do
      @importer = Importer.new(@transport = Transport.new)
      @importer.save_error(9, 'Something bad happened')
      @importer.save_error(11, 'Something else bad happened')
    end
    specify { @importer.errors.map {|e| [e.row, e.text]}.should == [[9, 'Something bad happened'], [11, 'Something else bad happened']]}
  end

  describe 'name' do
    before do
      @importer = Importer.new(@transport = Transport.new)
      @importer.stub(:model_class).and_return(Client)
    end
    specify { @importer.name.should == 'Client' }
  end
end