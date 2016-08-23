require 'spec_helper'

describe OrderExporter do

  before do
    @exporter = OrderExporter.new(@user = double, {period: 'p1', option: ['o2', 'o3'], distributor: ['d4', 'd5'], template: '4', ship_via: ['G&H'], participation_only_stores: true})
    Period.stub(:find).and_return(@period = double('Period'))
  end

  describe "orders_for_option" do
    before do
      Order.should_receive(:for_option).with(12).and_return orders = double('Orders')
      @exporter.should_receive(:query_and_map_orders).with(orders).and_return 'orders'
    end
    specify { @exporter.orders_for_option(double('Order', id: 12)).should == 'orders' }
  end

  describe "all_orders" do
    describe 'with selected options' do
      before do
        @exporter = OrderExporter.new(@user = double, {option: ['o2', 'o3']})
        Order.should_receive(:for_option).with(['o2', 'o3']).and_return orders = double('Orders')
        @exporter.should_receive(:query_and_map_orders).with(orders).and_return 'orders'
      end
      specify { @exporter.all_orders.should == 'orders' }
    end
    describe 'without selected options' do
      before do
        @exporter = OrderExporter.new(@user = double, {option: []})
        Order.should_receive(:where).with(nil).and_return orders = double('Orders')
        @exporter.should_receive(:query_and_map_orders).with(orders).and_return 'orders'
      end
      specify { @exporter.all_orders.should == 'orders' }
    end
  end

  describe 'query_and_map_orders' do
    before do
      @exporter.should_receive(:include_fields).and_return 'fields!'
      @orders = double('Orders')
      @orders.should_receive(:includes).with('fields!').and_return @orders
      @orders.should_receive(:for_period).with('p1').and_return @orders
      @orders.should_receive(:for_distribution).with(['d4', 'd5']).and_return @orders
      @orders.should_receive(:for_ship_via).with(['G&H']).and_return @orders
      @orders.should_receive(:for_participation_only_stores).and_return @orders
      @orders.should_receive(:map).and_return @orders
      @orders.should_receive(:sort).and_return @orders
    end
    specify { @exporter.query_and_map_orders(@orders).should == @orders }
  end

  describe 'include_fields' do
    describe 'all fields' do
      before do
        @exporter.should_receive(:require_postcode_table?).and_return true
        @exporter.should_receive(:require_table?).with('Page').and_return true
        @exporter.should_receive(:require_table?).with('Client').and_return true
        @exporter.should_receive(:require_address_table?).and_return true
      end
      specify { @exporter.include_fields.should == [:distributions, {distributions: :postcode_sectors}, {option: {values: [:page, :period]}}, {store: :client}, {store: :address}] }
    end
    describe 'no fields' do
      before do
        @exporter.should_receive(:require_postcode_table?).and_return false
        @exporter.should_receive(:require_address_table?).and_return false
        @exporter.should_receive(:require_table?).with('Option').and_return false
        @exporter.should_receive(:require_table?).with('Page').and_return false
        @exporter.should_receive(:require_table?).with('Period').and_return false
        @exporter.should_receive(:require_table?).with('Store').and_return false
        @exporter.should_receive(:require_table?).with('Client').and_return false
      end
      specify { @exporter.include_fields.should == [:distributions] }
    end
    describe 'some fields' do
      before do
        @exporter.should_receive(:require_postcode_table?).and_return false
        @exporter.should_receive(:require_address_table?).and_return false
        @exporter.should_receive(:require_table?).with('Page').and_return false
        @exporter.should_receive(:require_table?).with('Period').and_return true
        @exporter.should_receive(:require_table?).with('Client').and_return true
      end
      specify { @exporter.include_fields.should == [:distributions, {option: {values: [:page, :period]}}, {store: :client}] }
    end
  end

  describe 'require_address_table?' do
    describe 'Delivery Address' do
      before { @exporter.should_receive(:require_table?).with('Delivery Address').and_return true }
      specify { @exporter.require_address_table?.should be_true }
    end
    describe 'Store Address' do
      before do
        @exporter.should_receive(:require_table?).with('Delivery Address').and_return false
        @exporter.should_receive(:require_table?).with('Store Address').and_return true
      end
      specify { @exporter.require_address_table?.should be_true }
    end
    describe 'none' do
      before do
        @exporter.should_receive(:require_table?).with('Delivery Address').and_return false
        @exporter.should_receive(:require_table?).with('Store Address').and_return false
      end
      specify { @exporter.require_address_table?.should be_false }
    end
  end

  describe 'require_postcode_table?' do
    describe 'true' do
      before { @exporter.should_receive(:fields).and_return ["Client-Reference","Newspaper-Contract Number","Solus Team-Reference Number", "Store Delivery-Delivery Postcode"] }
      specify { @exporter.require_postcode_table?.should be_true }
    end
    describe 'false' do
      before { @exporter.should_receive(:fields).and_return ["Client-Reference","Newspaper-Contract Number","Solus Team-Reference Number"] }
      specify { @exporter.require_postcode_table?.should be_false }
    end
  end

  describe 'require_table?' do
    before { @exporter.should_receive(:export_tables).and_return ['Solus Team', 'Client', 'Store', 'Order', 'Option']}
    specify { @exporter.require_table?('Solus Team').should be_true }
    specify { @exporter.require_table?('Option').should be_true }
    specify { @exporter.require_table?('Period').should be_false }
  end

  describe 'export_tables' do
    before { @exporter.should_receive(:fields).and_return ["Client-Reference","Newspaper-Contract Number","Newspaper-Distribution Week","Option-Licenced","Order-Total Quantity", "Solus Team-Reference Number", "Store Delivery-Delivery Postcode"] }
    specify { @exporter.export_tables.should == ['Client', 'Newspaper', 'Option', 'Order', 'Solus Team', 'Store Delivery'] }
  end

  describe 'options' do
    describe 'without selected options' do
      before do
        @exporter = OrderExporter.new(@user = double, {option: []})
        @exporter.should_receive(:all_options).and_return @options = double('Options')
      end
      specify { @exporter.options.should == @options }
    end
    describe 'with selected options' do
      before do
        @exporter = OrderExporter.new(@user = double, {option: ['1,2,3']})
        @exporter.should_receive(:selected_options).and_return @options = double('Options')
      end
      specify { @exporter.options.should == @options }
    end
  end

  describe 'selected_options' do
    before do
      @exporter = OrderExporter.new(@user = double, {option: ['1','2','3']})
      Option.should_receive(:ordered).and_return @options = double('Options')
      @options.should_receive(:find).with(['1','2','3']).and_return @options
    end
    specify { @exporter.selected_options.should == @options }
  end

  describe 'all_options' do
    before do
      @exporter.should_receive(:period).and_return double('period', client_id: 12)
      Option.should_receive(:for_client).with(12).and_return @options = double
      @options.should_receive(:ordered).and_return @options
    end
    specify { @exporter.all_options.should == @options }
  end

  describe 'file_name' do
    before do
      @exporter.should_receive(:export_template).and_return double('ExportTemplate', name: 'Template1')
      Time.stub(:now).and_return Time.new(2013, 10, 23, 15, 20)
    end
    specify { @exporter.file_name.should == 'Template1-23Oct2013-1520.xls' }
  end

  describe 'spreadsheet' do
    describe 'only initializes the workbook once' do
      before do
        Spreadsheet::Workbook.should_receive(:new).and_return @spreadsheet = double
        @exporter.xls # force 1 call
      end
      specify { @exporter.xls.should == @spreadsheet }
    end
    describe 'is initialized' do
      specify { @exporter.xls.class.should == Spreadsheet::Workbook }
    end
  end

  describe 'sheet_for_option' do
    before do
      @exporter.should_receive(:xls).and_return @xls = double('XLS')
      @exporter.should_receive(:fields).and_return @fields = double('Fields')
      @xls.should_receive(:create_worksheet).with(name: 'B').and_return sheet = double('Sheet')
      ExcelSheet.should_receive(:new).with(sheet, @fields).and_return @sheet = double('OSheet')
    end
    specify { @exporter.sheet_for_option(double('Option', name: 'B')).should == @sheet }
  end

  describe 'write_orders' do
    describe 'on multiple tabs' do
      before do
        @exporter = OrderExporter.new(@user = double('User'), {split_options: '1'})
        @exporter.should_not_receive(:write_orders_on_one_tab)
        @exporter.should_receive(:write_orders_on_multiple_tabs).and_return true
      end
      specify { @exporter.write_orders.should be_true }
    end
    describe 'on one tab' do
      before do
        @exporter = OrderExporter.new(@user = double('User'), {split_options: nil})
        @exporter.should_not_receive(:write_orders_on_multiple_tabs)
        @exporter.should_receive(:write_orders_on_one_tab).and_return true
      end
      specify { @exporter.write_orders.should be_true }
    end
  end

  describe 'write_orders_on_one_tab' do
    before do
      @exporter.should_receive(:all_orders).and_return all_orders = double('All Orders')
      @exporter.should_receive(:fields).and_return 'Fields!'
      @exporter.should_receive(:xls).and_return xls = double('XLS')
      xls.should_receive(:create_worksheet).with({name: 'Orders'}).and_return worksheet = double('Worksheet')

      ExcelSheet.should_receive(:new).with(worksheet, 'Fields!').and_return @sheet = double('OSheet')
      @sheet.should_receive(:write_orders).with(all_orders, @period)
    end
    specify { @exporter.write_orders_on_one_tab.should be_nil }
  end

  describe 'write_orders_on_multiple_tabs' do
    before do
      @exporter.stub(:options).and_return [@option1 = double('Option1'), @option2 = double('Option2')]
      @exporter.should_receive(:write_orders_for_option).with(@option1)
      @exporter.should_receive(:write_orders_for_option).with(@option2)
    end
    describe 'with orders' do
      before do
        @exporter.should_receive(:xls).and_return(double('XLS', worksheets: ['worksheet']))
        @exporter.should_not_receive(:sheet_for_option)
      end
      specify { @exporter.write_orders_on_multiple_tabs.should be_nil }
    end
    describe 'without any orders' do
      before do
        @exporter.should_receive(:xls).and_return(double('XLS', worksheets: []))
        @exporter.should_receive(:sheet_for_option).with(@option1)
      end
      specify { @exporter.write_orders_on_multiple_tabs.should be_nil }
    end
  end

  describe 'write_orders_for_option' do
    describe 'with no orders' do
      before do
        @exporter.should_receive(:orders_for_option).with(@option = double('Option')).and_return []
        @exporter.should_not_receive(:write_orders_to_sheet)
      end
      specify { @exporter.write_orders_for_option(@option).should be_false }
    end
    describe 'with 2 orders' do
      before do
        @exporter.should_receive(:orders_for_option).with(@option = double('Option')).and_return [@order1 = double('Order1'), @order2 = double('Order2')]
        @exporter.should_receive(:sheet_for_option).with(@option).and_return @sheet = double('Sheet')
        @sheet.should_receive(:write_orders).with([@order1, @order2], @period, @option)
      end
      specify { @exporter.write_orders_for_option(@option).should be_nil }
    end
  end

  describe 'fields' do
    before do
      @exporter.should_receive(:export_template).and_return double('ExportTemplate', value: 'Name,Account Number,Description,Client')
      @exporter.fields
    end
    specify { @exporter.fields.should == ['Name', 'Account Number', 'Description', 'Client'] }
  end

  describe 'export_template' do
    before do
      ExportTemplate.should_receive(:find).with('4').and_return @template = double('ExportTemplate')
      @exporter.export_template
    end
    specify { @exporter.export_template.should == @template }
  end

  describe 'export' do
    before do
      @exporter.should_receive :write_orders
      @exporter.should_receive(:raw_data).and_return('data')
    end
    specify { @exporter.export.should == 'data'}
  end

  describe 'raw_data' do
    before do
      @xls = double
      StringIO.should_receive(:new).and_return @data = double(string: 'ok')
      @xls.should_receive(:write).with(@data)
      @exporter.should_receive(:xls).and_return @xls
    end
    specify { @exporter.raw_data.should == 'ok' }
  end

  describe 'Sheet' do
    before { @osheet = ExcelSheet.new(@sheet = double('Sheet'), @fields = ['Name', 'Account Number', 'Description', 'Client']) }
    describe 'write_header' do
      before do
        @sheet.stub(:row).with(1).and_return(double('Row', 'height=' => '', 'set_format' => ''))
        @sheet.should_receive(:[]=).with(1, 0, 'Name')
        @sheet.should_receive(:[]=).with(1, 1, 'Account Number')
        @sheet.should_receive(:[]=).with(1, 2, 'Description')
        @sheet.should_receive(:[]=).with(1, 3, 'Client')
      end
      specify { @osheet.write_header.should == @fields}
    end

    describe 'write_orders' do
      before do
        @orders = [@order1 = double('Order1'), @order2 = double('Order2'), @order3 = double('Order3')]
        @osheet.should_receive(:write_header)
        @osheet.should_receive(:set_column_widths).and_return({})
        @sheet.should_receive(:[]=).with(0, 0, anything)
        @sheet.stub(:row).with(0).and_return(double('Row', 'height=' => '', 'set_format' => ''))
        @osheet.should_receive(:write_order_at).with(@order1, 2)
        @osheet.should_receive(:write_order_at).with(@order2, 3)
        @osheet.should_receive(:write_order_at).with(@order3, 4)
      end
      specify { @osheet.write_orders(@orders, FactoryGirl.build(:period)).should == {} }
    end

    describe 'write_order_at' do
      before do
        @sheet.stub(:row).with(4).and_return(double('Row', 'height=' => '', 'set_format' => ''))
        @sheet.should_receive(:[]=).with(4,0, 64)
        @sheet.should_receive(:[]=).with(4,1, 'SB342423')
        @sheet.should_receive(:[]=).with(4,2, 'NISA')
        @sheet.should_receive(:[]=).with(4,3, 445)
        @order = double('OrderRow')
        @order.should_receive(:value).with('Name').and_return(64)
        @order.should_receive(:value).with('Account Number').and_return('SB342423')
        @order.should_receive(:value).with('Description').and_return('NISA')
        @order.should_receive(:value).with('Client').and_return(445)
      end
      specify { @osheet.write_order_at(@order, 4).should == @fields}
    end
  end    

  describe 'OrderRow' do

    before { @row = OrderExporter::OrderRow.new(@order = Order.new, @period = Period.new) }
    describe 'delegates' do
      before do
        @store = @order.store = Store.new
        @distributions = @order.distributions = [Distribution.new]
      end
      specify { @row.store.should == @store }
      specify { @row.distributions.should == @distributions }
    end

    describe 'order_value' do
      describe 'for distribution field' do
        before do
          @row.should_receive(:distribution_field?).with('solus team-total boxes').and_return true
          @row.should_receive(:distribution_value).with('solus team-total boxes').and_return 69
        end
        specify { @row.value('Solus Team-Total Boxes').should == 69 }
      end
      describe 'for order' do
        before { @order.attributes = {total_quantity: 550, total_price: 5943, distribution_week: 7, status: 2} }
        describe 'total quantity' do
          before { @row.should_receive(:distribution_field?).with('order-total quantity').and_return false }
          specify { @row.value('Order-Total Quantity').should == 550 }
        end
        describe 'total price' do
          before { @row.should_receive(:distribution_field?).with('order-total price').and_return false }
          specify { @row.value('Order-Total Price').should == 5943 }
        end
        describe 'distribution week' do
          before { @row.should_receive(:distribution_field?).with('order-distribution week').and_return false }
          specify { @row.value('Order-Distribution Week').should == 7 }
        end
        describe 'status' do
          before { @row.should_receive(:distribution_field?).with('order-status').and_return false }
          specify { @row.value('Order-Status').should == 'In Print' }
        end
      end
      describe 'for client' do
        before do
          @order.store = Store.new
          @order.store.client = Client.new(name: 'NISA')
        end
        describe 'name' do
          before { @row.should_receive(:distribution_field?).with('client-name').and_return false }
          specify { @row.value('Client-Name').should == 'NISA' }
        end
      end
      describe 'for option' do
        before do
          @order.option = Option.new(name: 'B', licenced: true)
          @order.option.stub(page: Page.new(box_quantity: 50))
        end
        describe 'name' do
          before { @row.should_receive(:distribution_field?).with('option-name').and_return false }
          specify { @row.value('Option-Name').should == 'B' }
        end
        describe 'licenced' do
          before { @row.should_receive(:distribution_field?).with('option-licenced').and_return false }
          specify { @row.value('Option-Licenced').should == true }
        end
      end
      describe 'for store' do
        before { @order.store = Store.new(account_number: 'AB0945', reference_number: 'ABCDE', postcode: 'XYZ 054') }
        describe 'account number' do
          before { @row.should_receive(:distribution_field?).with('store-account number').and_return false }
          specify { @row.value('Store-Account Number').should == 'AB0945' }
        end
        describe 'reference number' do
          before { @row.should_receive(:distribution_field?).with('store-reference number').and_return false }
          specify { @row.value('Store-Reference Number').should == 'ABCDE' }
        end
        describe 'postcode' do
          before { @row.should_receive(:distribution_field?).with('store-postcode').and_return false }
          specify { @row.value('Store-Postcode').should == 'XYZ 054' }
        end
      end
      describe 'for page' do
        before { @order.period_id = 12 }
        describe 'when nil' do
          before { @row.should_receive(:distribution_field?).with('page-name').and_return false }
          specify { @row.value('Page-Name').should be_nil }
        end
        describe 'when not nil' do
          before do
            @order.option = Option.new
            @order.option.should_receive(:page_for_period).with(12).and_return Page.new(name: 'A4 6 Sheets', box_quantity: 50)
          end
          describe 'name' do
            before { @row.should_receive(:distribution_field?).with('page-name').and_return false }
            specify { @row.value('Page-Name').should == 'A4 6 Sheets' }
          end
          describe 'box quantity' do
            before { @row.should_receive(:distribution_field?).with('page-box quantity').and_return false }
            specify { @row.value('Page-Box Quantity').should == 50 }
          end
        end
      end
      describe 'for store address' do
        before { @order.store = Store.new }
        describe 'when nil' do
          before { @order.store.should_receive(:store_address).and_return nil }
          specify { @row.value('Store Address-City').should be_nil }
        end
        describe 'when not nil' do
          before { @order.store.should_receive(:store_address).and_return double('Address', county: 'Cornwall', email: 'steve@apple.co') }
          describe 'line1' do
            specify { @row.value('Store Address-County').should == 'Cornwall' }
          end
          describe 'city' do
            specify { @row.value('Store Address-Email').should == 'steve@apple.co' }
          end
        end
      end
    end

    describe 'distribution_field?' do
      describe 'true' do
        before { @row.should_receive(:distribution_matching).with('x').and_return Distribution.new }
        specify { @row.distribution_field?('x').should be_true }
      end
      describe 'false' do
        before { @row.should_receive(:distribution_matching).with('x').and_return nil }
        specify { @row.distribution_field?('x').should be_false }
      end
    end

    describe 'distribution_value' do
      describe 'without distribution' do
        before { @row.should_receive(:distribution_matching).with('x').and_return nil }
        specify { @row.distribution_value('x').should be_nil }
      end
      describe 'with distribution' do
        before do
          d = Distribution.new(distribution_week: -1, total_quantity: 450, contract_number: 'ABCD', reference_number: '450')
          d.address = Address.new(city: 'London', business_name: 'Kramerica Industries')
          d.postcode_sectors = [PostcodeSector.new(area: 'SW', district: 18, sector: 8), PostcodeSector.new(area: 'EC1', district: 12, sector: 9)]
          d.stub(:calculate_box_count).and_return 5
          @row.should_receive(:distribution_matching).and_return d
          @period.date_promo = Date.new(2013, 9, 16)
          @period.week_number = 901
        end
        specify { @row.distribution_value('solus team-date of distribution').should == '09 September 2013' }
        specify { @row.distribution_value('solus team-distribution week').should == '09 September 2013' }
        specify { @row.distribution_value('solus team-total quantity').should == 450 }
        specify { @row.distribution_value('solus team-total boxes').should == 5 }
        specify { @row.distribution_value('solus team-contract number').should == 'ABCD' }
        specify { @row.distribution_value('solus team-reference number').should == '450' }
        specify { @row.distribution_value('solus team-delivery postcode').should == 'SW18 8, EC112 9' }
        specify { @row.distribution_value('solus team-address city').should == 'London' }
        specify { @row.distribution_value('solus team-address business name').should == 'Kramerica Industries' }
        specify { @row.distribution_value('solus team-leaflet number').should == '900/450' }
      end
    end

    describe 'address_field?' do
      specify { @row.address_field?('solus team-address first line').should be_true }
      specify { @row.address_field?('solus team-first line').should be_false }
    end

    describe 'distribution_address_value' do
      describe 'without address' do
        specify { @row.distribution_address_value(double('Distribution', address: nil), 'solus team-address first line').should be_nil }
      end
      describe 'with address' do
        let(:address) { Address.new(first_line: '56 Someplace St') }
        specify { @row.distribution_address_value(double('Distribution', address: address), 'solus team-address first line').should == '56 Someplace St' }
      end
    end

    describe 'distribution_week' do
      before { @period.date_promo = Date.new(2013, 10, 14) }
      specify { @row.distribution_week(Distribution.new(distribution_week: -1)).should == '07 October 2013' }
    end

    describe 'distribution_leaflet_number' do
      before { @period.week_number = 345 }
      describe 'without reference number' do
        specify { @row.distribution_leaflet_number(Distribution.new(distribution_week: 0)).should be_nil}
      end
      describe 'with reference number' do
        specify { @row.distribution_leaflet_number(Distribution.new(distribution_week: 0, reference_number: '645')).should == '345/645'}
        specify { @row.distribution_leaflet_number(Distribution.new(distribution_week: 1, reference_number: '645')).should == '346/645'}
      end
    end

    describe 'delivery_postcode' do
      specify { @row.delivery_postcode(double('Distribution', postcode_sectors: [])).should == '' }
      specify { @row.delivery_postcode(double('Distribution', postcode_sectors: [PostcodeSector.new(area: 'SW', district: 18, sector: 8)])).should == 'SW18 8' }
      specify { @row.delivery_postcode(double('Distribution', postcode_sectors: [PostcodeSector.new(area: 'SW', district: 18, sector: 8), PostcodeSector.new(area: 'EC1', district: 12, sector: 9)])).should == 'SW18 8, EC112 9' }
    end

    describe 'distribution_matching' do
      describe 'solus team' do
        before { @row.should_receive(:solus_team).and_return @d = double('solus team') }
        specify { @row.distribution_matching('solus team-total boxes').should == @d }
      end
      describe 'newspaper' do
        before { @row.should_receive(:newspaper).and_return @d = double('newspaper') }
        specify { @row.distribution_matching('newspaper-distribution week').should == @d }
      end
      describe 'store delivery' do
        before { @row.should_receive(:store_delivery).and_return @d = double('store delivery') }
        specify { @row.distribution_matching('store delivery-total quantity').should == @d }
      end
      describe 'royal mail' do
        before { @row.should_receive(:royal_mail).and_return @d = double('royal mail') }
        specify { @row.distribution_matching('royal mail-contract number').should == @d }
      end
      describe 'none' do
        specify { @row.distribution_matching('store-reference number').should be_nil }
      end
    end

    describe 'sort' do
      let(:row1) {
        row = OrderExporter::OrderRow.new(nil, nil)
        row.stub(:store).and_return double('Store', running_order: 4)
        row
      }
      let(:row2) {
        row = OrderExporter::OrderRow.new(nil, nil)
        row.stub(:store).and_return double('Store', running_order: nil)
        row
      }
      let(:row3) {
        row = OrderExporter::OrderRow.new(nil, nil)
        row.stub(:store).and_return double('Store', running_order: 1)
        row
      }
      specify { [row1, row2, row3].sort.should == [row3, row1, row2] }
    end

    describe 'newspaper' do
      describe 'without row' do
        before { @row.should_receive(:distributions).and_return [double(newspaper?: false), double(newspaper?: false)] }
        specify { @row.newspaper.should be_nil }
      end
      describe 'with row' do
        before { @row.should_receive(:distributions).and_return [double(newspaper?: false), @dist = double(newspaper?: true)] }
        specify { @row.newspaper.should == @dist }
      end
    end
    describe 'royal_mail' do
      describe 'without row' do
        before { @row.should_receive(:distributions).and_return [double(royal_mail?: false), double(royal_mail?: false)] }
        specify { @row.royal_mail.should be_nil }
      end
      describe 'with row' do
        before { @row.should_receive(:distributions).and_return [double(royal_mail?: false), @dist = double(royal_mail?: true)] }
        specify { @row.royal_mail.should == @dist }
      end
    end
    describe 'solus_team' do
      describe 'without row' do
        before { @row.should_receive(:distributions).and_return [double(solus_team?: false), double(solus_team?: false)] }
        specify { @row.solus_team.should be_nil }
      end
      describe 'with row' do
        before { @row.should_receive(:distributions).and_return [double(solus_team?: false), @dist = double(solus_team?: true)] }
        specify { @row.solus_team.should == @dist }
      end
    end
    describe 'store_delivery' do
      describe 'without row' do
        before { @row.should_receive(:distributions).and_return [double(store_delivery?: false), double(store_delivery?: false)] }
        specify { @row.store_delivery.should be_nil }
      end
      describe 'with row' do
        before { @row.should_receive(:distributions).and_return [double(store_delivery?: false), @dist = double(store_delivery?: true)] }
        specify { @row.store_delivery.should == @dist }
      end
    end
  end
end