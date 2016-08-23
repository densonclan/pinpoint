# encoding: utf-8
require 'spec_helper'

describe OrderImporter do

  before { @importer = OrderImporter.new(@transport = Transport.new) }
  describe 'model_class' do
    specify { @importer.model_class.should == Order }
  end

  describe 'field_names' do
    before { Distributor.should_receive(:all).and_return [double(name: 'Store Delivery'), double(name: 'Royal Mail')] }
    specify { @importer.class.field_names.should == \
      ['account_number', 'period', 'option', 'total_price', 'status', \
      'store_delivery_total_quantity', 'store_delivery_notes', 'store_delivery_contract_number', 'store_delivery_reference_number', 'store_delivery_distribution_week',
      'royal_mail_total_quantity', 'royal_mail_notes', 'royal_mail_contract_number', 'royal_mail_reference_number', 'royal_mail_distribution_week']
    }
  end

  describe 'skip_row' do
    describe 'should be true' do
      describe 'if option not set' do
        specify { @importer.skip_row?({'account_number' => '12345'}).should be_true }
      end
      describe 'if total is zero' do
        before { @importer.should_receive(:sum_totals).with({'option' => 'B', 'account_number' => '12345'}).and_return 0 }
        specify { @importer.skip_row?({'option' => 'B', 'account_number' => '12345'}).should be_true }
      end
    end
    describe 'should be false' do
      before { @importer.should_receive(:sum_totals).with({'account_number' => '12345', 'option' => 'B'}).and_return 500 }
      describe 'if option is set' do
        specify { @importer.skip_row?({'account_number' => '12345', 'option' => 'B'}).should be_false }
      end
    end
  end

  describe 'find_or_create_object' do
    describe 'with invalid store' do
      before { Store.should_receive(:find_by_account_number).with('12345').and_return nil }
      specify { @importer.find_or_create_object('account_number' => '12345').attributes.should == Order.new.attributes }
    end
    describe 'with existing order' do
      before do
        Store.should_receive(:find_by_account_number).with('12345').and_return store = Store.new
        store.should_receive(:orders).and_return @order = double
        @order.should_receive(:for_current_period).and_return @order
        @order.should_receive(:first).and_return @order
      end
      specify { @importer.find_or_create_object('account_number' => '12345').should == @order }
    end
    describe 'without existing order' do
      before do
        Store.should_receive(:find_by_account_number).with('12345').and_return @store = Store.new
        @store.should_receive(:orders).and_return @order = double
        @order.should_receive(:for_current_period).and_return @order
        @order.should_receive(:first).and_return nil
      end
      specify { @importer.find_or_create_object('account_number' => '12345').attributes.should == Order.new(store: @store).attributes }
      specify { @importer.find_or_create_object('account_number' => '12345').store.should == @store }
    end
  end

  describe 'set_extra_attributes' do
    before do
      @row = {'period' => 'periodx', 'option' => 'optiony', 'page' => 'pagez'}
      @importer.should_receive(:set_period).with(@order = Order.new(store: Store.new), 'periodx', 9)
      @importer.should_receive(:set_option).with(@order, 'optiony', 9)
      @importer.should_receive(:set_distributions).with(@order, @row)
      @order.stub(:store).and_return double
      @importer.set_extra_attributes(@order, @row, 9 )
    end
    specify { @order.updated_by.should == @user }
  end

  describe 'set_period' do
    describe 'when blank' do
      before do
        @importer.should_receive(:current_period_for).with(12).and_return @period = Period.new
        @importer.set_period(@order = Order.new(store: Store.new(client_id: 12)), '', 9)
      end
      specify { @order.period.should == @period }
    end
    describe 'with invalid period number' do
      before do
        Period.should_receive(:for_client).with(6).and_return periods = double
        periods.should_receive(:find_by_period_number).with('xyz').and_return nil
        @importer.should_receive(:save_error).with(9, "Unrecognised period number 'xyz' for NISA. Valid values are: 1, 2, 3, 4")
        @importer.should_receive(:period_number_options).with(6).and_return '1, 2, 3, 4'
        store = Store.new
        store.client = Client.new(name: 'NISA')
        store.stub(:client_id).and_return 6
        @importer.set_period(@order = Order.new(store: store), 'xyz', 9)
      end
      specify { @order.period.should be_nil }
    end
    describe 'with valid period number' do
      before do
        Period.should_receive(:for_client).with(6).and_return periods = double
        periods.should_receive(:find_by_period_number).with('xyz').and_return @period = Period.new
        @importer.should_not_receive(:save_error)
        @importer.set_period(@order = Order.new(store: Store.new(client_id: 6)), 'xyz', 9)
      end
      specify { @order.period.should == @period }
    end
  end

  describe 'period_options' do
    before { Period.should_receive(:for_client).with(12).and_return [double(period_number: 1),double(period_number: 2),double(period_number: 3),double(period_number: 4),double(period_number: 5)] }
    specify { @importer.period_number_options(12).should == '1, 2, 3, 4, 5' }
  end

  describe 'set_option' do
    describe 'when blank' do
      before { @importer.should_receive(:save_error).with(9, 'Option missing') }
      specify { @importer.set_option(Order.new, '', 9) }
    end
    describe 'with invalid option number' do
      before do
        Option.should_receive(:for_client).with(6).and_return(options = double)
        options.should_receive(:named).with('xyz').and_return double(first: nil)
        @importer.should_receive(:save_error).with(9, "Unrecognised option number 'xyz' for NISA. Valid values are: A, B, C, D")
        @importer.should_receive(:option_options).with(6).and_return 'A, B, C, D'
        store = Store.new
        store.client = Client.new(name: 'NISA')
        store.stub(:client_id).and_return 6
        @importer.set_option(@order = Order.new(store: store), 'xyz', 9)
      end
      specify { @order.option.should be_nil }
    end
    describe 'with valid option number' do
      before do
        Option.should_receive(:for_client).with(6).and_return(options = double)
        options.should_receive(:named).with('xyz').and_return double(first: @option = Option.new)
        @importer.should_not_receive(:save_error)
        @importer.set_option(@order = Order.new(store: Store.new(client_id: 6)), 'xyz', 9)
      end
      specify { @order.option.should == @option }
    end
  end

  describe 'option_options' do
    before { Option.should_receive(:names_for_client).with(@client = double).and_return %w(A B C D) }
    specify { @importer.option_options(@client).should == 'A, B, C, D' }
  end

  describe 'distributors' do
    before { Distributor.should_receive(:all).and_return(@distributors = double) }
    specify { @importer.distributors.should == @distributors }
  end

  describe 'set_distributions' do
    before do
      @importer.should_receive(:distributors).and_return([double(id: 5, name: 'Frank'), double(id: 6, name: 'Harry Reid')])
      @importer.stub(:headers).and_return ['account_number', 'code', 'frank_total_quantity', 'frank_contract_number', 'frank_reference_number', \
        'harry_reid_total_quantity', 'harry_reid_contract_number', 'harry_reid_reference_number']
      row = {'frank_total_quantity' => '500', 'frank_contract_number' => '3', 'frank_reference_number' => 'xyz', \
        'harry_reid_total_quantity' => '12', 'harry_reid_contract_number' => '80', 'harry_reid_reference_number' => 'POP'}
      @importer.set_distributions(@order = Order.new, row)
    end
    specify { @order.distributions.length.should == 2 }
    specify { @order.distributions[0].attributes.slice(*['distributor_id', 'total_quantity', 'reference_number', 'contract_number']).should == {'distributor_id' => 5, 'total_quantity' => 500, 'reference_number' => 'xyz', 'contract_number' => '3'}}
    specify { @order.distributions[1].attributes.slice(*['distributor_id', 'total_quantity', 'reference_number', 'contract_number']).should == {'distributor_id' => 6, 'total_quantity' => 12, 'reference_number' => 'POP', 'contract_number' => '80'}}
  end

  describe 'extract_reference_number' do
    describe 'when blank' do
      specify { @importer.extract_reference_number('').should be_nil }
    end
    describe 'when not matched' do
      specify { @importer.extract_reference_number('ABC').should == 'ABC' }
    end
    describe 'when matched' do
      specify { @importer.extract_reference_number('123/456').should == '456' }
    end
  end

  describe 'distribution_for_order' do
    before do
      @order = Order.new
      @order.distributions = [@distribution = Distribution.new(distributor_id: 4)]
    end
    describe 'existing distribution' do
      specify { @importer.distribution_for_order(@order, 4).should == @distribution }
    end
    describe 'new distribution' do
      specify { @importer.distribution_for_order(@order, 5).attributes.should == Distribution.new(distributor_id: 5).attributes }
    end
  end

  describe 'distribution_week' do
    describe 'with nil date' do
      before { @importer.should_receive(:extract_distribution_date_from_string).with('abc').and_return nil }
      specify { @importer.distribution_week(double, 'abc').should be_nil }
    end
    describe 'with valid date' do
      before do
        @importer.should_receive(:extract_distribution_date_from_string).with('abc').and_return DateTime.new(2013, 10, 1)
      end
      specify { @importer.distribution_week(double(period: double(date_promo: Date.new(2013, 10, 8))), 'abc').should == -1 }
    end
  end

  describe 'extract_distribution_date_from_string' do
    describe 'with null string' do
      specify { @importer.extract_distribution_date_from_string(nil).should be_nil }
    end
    describe 'with empty string' do
      specify { @importer.extract_distribution_date_from_string('').should be_nil }
    end
    describe 'with just date' do
      specify { @importer.extract_distribution_date_from_string('25th December 2005').should == DateTime.new(2005, 12, 25) }
    end
    describe 'with w/c and date' do
      specify { @importer.extract_distribution_date_from_string('w/c 1st January 2013').should == DateTime.new(2013, 1, 1) }
    end
    describe 'with w/c, date and days' do
      specify { @importer.extract_distribution_date_from_string('w/c 2nd February 2013 (Thurs to Fri)').should == DateTime.new(2013, 2, 2) }
    end
    describe 'handle invalid date' do
      specify { @importer.extract_distribution_date_from_string('w/c 31st February 2013 (Thurs to Fri)').should be_nil }
    end
    describe 'handle invalid string' do
      specify { @importer.extract_distribution_date_from_string('w/c )').should be_nil }
    end
  end

  # describe 'end to end' do
  #   before(:all) do
  #     client1 = create_a(:client)
  #     client2 = create_a(:client)
  #     @store1 = create_a(:just_store, account_number: 'C01093', client: client1)
  #     @store2 = create_a(:just_store, account_number: 'C13400', client: client1)
  #     @store3 = create_a(:just_store, account_number: 'C21045', client: client1)
  #     @store4 = create_a(:just_store, account_number: 'C24881', client: client1)
  #     @store5 = create_a(:just_store, account_number: 'C25476', client: client2)
  #     @store6 = create_a(:just_store, account_number: 'C26247', client: client2)
  #     @store7 = create_a(:just_store, account_number: 'C29292', client: client2)
  #     @store8 = create_a(:just_store, account_number: 'G12000', client: client2)
  #     @store9 = create_a(:just_store, account_number: 'H15100', client: client2)
  #     @store10 = create_a(:just_store, account_number: 'M24504', client: client2)
  #     @period1 = create_a(:period, period_number: 1, client: client1)
  #     @period2 = create_a(:period, period_number: 2, client: client1)
  #     @period3 = create_a(:period, period_number: 3, client: client1)
  #     @period4 = create_a(:period, period_number: 4, client: client1)
  #     @period5 = create_a(:period, period_number: 5, client: client1)
  #     @period6 = create_a(:period, period_number: 1, client: client2)
  #     @option1 = create_a(:option, name: 'A', client: client1)
  #     @option2 = create_a(:option, name: 'C', client: client1)
  #     @option3 = create_a(:option, name: 'D', client: client1)
  #     @option4 = create_a(:option, name: 'E', client: client1)
  #     @option5 = create_a(:option, name: 'X', client: client2)
  #     @option6 = create_a(:option, name: 'G', client: client2)
  #     @option7 = create_a(:option, name: 'D', client: client2)
  #     @option8 = create_a(:option, name: 'SD', client: client2)
  #     @option9 = create_a(:option, name: 'X', client: client2)
  #     @page1 = create_a(:page, name: 'A4 4 Pages')
  #     @page2 = create_a(:page, name: 'A4 12 Pages')
  #     @distributor1 = create_a(:distributor, name: 'Store Delivery')
  #     @distributor2 = create_a(:distributor, name: 'Solus Team')
  #     @distributor3 = create_a(:distributor, name: 'Royal Mail')
  #     @distributor4 = create_a(:distributor, name: 'Newspaper')
  #     @user = create_a(:user)
  #     file = File.open Rails.root.join('test', 'fixtures', 'files', 'orders.csv')

  #     OrderImporter.new(@user, file).import!
  #   end
  #   after(:all) do
  #     delete_all %w(clients stores periods options pages distributors orders distributions versions users)
  #   end
  #   specify { Order.count.should == 11 }
  #   specify { @store1.orders.length.should == 2 }
  #   specify { @store2.orders.length.should == 1 }
  #   specify { @store3.orders.length.should == 1 }
  #   specify { @store4.orders.length.should == 1 }
  #   specify { @store5.orders.length.should == 1 }
  #   specify { @store6.orders.length.should == 1 }
  #   specify { @store7.orders.length.should == 1 }
  #   specify { @store8.orders.length.should == 1 }
  #   specify { @store9.orders.length.should == 1 }
  #   specify { @store10.orders.length.should == 1 }
  #   describe 'order1' do
  #     before { @order = @store1.orders.select {|o| o.period == @period1}.first }
  #     specify { @order.option.should == @option1 }
  #     specify { @order.page.should == @page2 }
  #     specify { @order.total_price.should == 1233 }
  #     specify { @order.distribution_week.should == 1 }
  #     specify { @order.status.should == Order::AWAITING_PRINT }
  #     describe 'distributions' do
  #       specify { @order.distributions.length.should == 2 }
  #       describe 'distribution1' do
  #         before { @distribution = @order.distributions.select {|d| d.distributor == @distributor1}.first }
  #         specify { @distribution.total_quantity.should == 400 }
  #         specify { @distribution.total_boxes.should == 3 }
  #         specify { @distribution.distribution_week.should == 1 }
  #         specify { @distribution.description.should == 'Leave with reception' }
  #         specify { @distribution.reference_number.should == 'XYZ123' }
  #         specify { @distribution.contract_number.should == '998877' }
  #       end
  #       describe 'distribution2' do
  #         before { @distribution = @order.distributions.select {|d| d.distributor == @distributor2}.first }
  #         specify { @distribution.total_quantity.should == 33 }
  #         specify { @distribution.total_boxes.should == 1 }
  #         specify { @distribution.distribution_week.should == 0 }
  #       end
  #     end
  #   end
  #   describe 'order2' do
  #     before { @order = @store1.orders.select {|o| o.period == @period2}.first }
  #     specify { @order.option.should == @option2 }
  #     specify { @order.page.should == @page2 }
  #     specify { @order.total_price.should == 342 }
  #     specify { @order.distribution_week.should == 2 }
  #     specify { @order.status.should == Order::IN_PRINT }
  #     describe 'distributions' do
  #       specify { @order.distributions.length.should == 2 }
  #       describe 'distribution1' do
  #         before { @distribution = @order.distributions.select {|d| d.distributor == @distributor1}.first }
  #         specify { @distribution.total_quantity.should == 500 }
  #         specify { @distribution.total_boxes.should == 4 }
  #         specify { @distribution.distribution_week.should == 1 }
  #       end
  #       describe 'distribution2' do
  #         before { @distribution = @order.distributions.select {|d| d.distributor == @distributor2}.first }
  #         specify { @distribution.total_quantity.should == 33 }
  #         specify { @distribution.total_boxes.should == 1 }
  #         specify { @distribution.distribution_week.should == 0 }
  #       end
  #     end
  #   end
  #   describe 'order3' do
  #     before { @order = @store2.orders.first }
  #     specify { @order.option.should == @option3 }
  #     specify { @order.page.should == @page2 }
  #     specify { @order.total_price.should == 24534 }
  #     specify { @order.distribution_week.should == 1 }
  #     specify { @order.status.should == Order::AWAITING_PRINT }
  #     describe 'distributions' do
  #       specify { @order.distributions.length.should == 1 }
  #       describe 'distribution1' do
  #         before { @distribution = @order.distributions.select {|d| d.distributor == @distributor1}.first }
  #         specify { @distribution.total_quantity.should == 400 }
  #         specify { @distribution.total_boxes.should == 3 }
  #         specify { @distribution.distribution_week.should == 1 }
  #       end
  #     end
  #   end
  #   describe 'order4' do
  #     before { @order = @store3.orders.first }
  #     specify { @order.option.should == @option3 }
  #     specify { @order.page.should == @page2 }
  #     specify { @order.total_price.should == 64534 }
  #     specify { @order.distribution_week.should == 2 }
  #     specify { @order.status.should == Order::AWAITING_PRINT }
  #     describe 'distributions' do
  #       specify { @order.distributions.length.should == 2 }
  #       describe 'distribution1' do
  #         before { @distribution = @order.distributions.select {|d| d.distributor == @distributor1}.first }
  #         specify { @distribution.total_quantity.should == 600 }
  #         specify { @distribution.total_boxes.should == 4 }
  #         specify { @distribution.distribution_week.should == 1 }
  #       end
  #       describe 'distribution2' do
  #         before { @distribution = @order.distributions.select {|d| d.distributor == @distributor3}.first }
  #         specify { @distribution.total_quantity.should == 444 }
  #         specify { @distribution.total_boxes.should == 4 }
  #         specify { @distribution.distribution_week.should == 5 }
  #         specify { @distribution.description.should == 'Tip the postie' }
  #         specify { @distribution.reference_number.should == "'test'" }
  #         specify { @distribution.contract_number.should == 'ABC999' }
  #       end
  #     end
  #   end
  # end
end

# Account Number,Period,Option,Page,Total Price,Distribution Week,Status,Store Delivery Total Quantity,Store Delivery Total Boxes,Store Delivery Description,Store Delivery Contract Number,Store Delivery Reference Number,Store Delivery Distribution Week,Solus Team Total Quantity,Solus Team Total Boxes,Solus Team Description,Solus Team Contract Number,Solus Team Reference Number,Solus Team Distribution Week,Royal Mail Total Quantity,Royal Mail Total Boxes,Royal Mail Description,Royal Mail Contract Number,Royal Mail Reference Number,Royal Mail Distribution Week,Newspaper Total Quantity,Newspaper Total Boxes,Newspaper Description,Newspaper Contract Number,Newspaper Reference Number,Newspaper Distribution Week
# C01093,1,A,A4 12 Pages,1233,1,,400,3,Leave with reception,998877,XYZ123,1,33,,,,,,,,,,,,,,,,,
# C01093,2,C,A4 12 Pages,342,2,2,500,4,,,,1,33,,,,,,,,,,,,,,,,,
# C13400,3,D,A4 12 Pages,24534,1,,400,3,,,,1,,,,,,,,,,,,,,,,,,
# C21045,4,D,A4 12 Pages,64534,2,,600,4,,,,1,,,,,,,444,4,Tip the postie,ABC999,'test',5,,,,,,
# C24881,5,E,A4 12 Pages,33,-5,,1,6,,,"comma,and ÒquotesÓ",11,,,,,,,,,,,,,,,,,,
# C25476,1,X,A4 12 Pages,3423,3.2,,2023,33,,,,1,,,,,,,,,,,,,,,,,,
# C26247,1,G,A4 12 Pages,34542,2,,34,5,,,,1,,,,,,,,,,,,,,,,,,
# C29292,1,G,A4 12 Pages,12,1,,23,3,,,,1,444,,,,,,,,,,,,,,,,,
# G12000,1,D,A4 12 Pages,4,3,,234,1,,,,1,,,,,,,,,,,,,,,,,,
# H15100,1,SD,A4 12 Pages,32,3,,346345,555,,,,88,,,,,,,,,,,,,,,,,,
# M24504,1,X,A4 12 Pages,2323.2,3,,222,22,,,,2,22,,,,,,,,,,,,,,,,,
