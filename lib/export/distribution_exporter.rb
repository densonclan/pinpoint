require 'spreadsheet'

class DistributionExporter

  def initialize(user, options)
    @user = user
    @options = options
  end

  def distributions_for_option(option)
    query_and_map_distributions Distribution.for_option(option.id)
  end

  def all_distributions
    query_and_map_distributions @options[:option].blank? ? Distribution.scoped : Distribution.for_option(@options[:option])
  end

  def query_and_map_distributions(distributions)
    distributions = distributions.includes(include_fields).for_period(@options[:period])
    distributions = distributions.for_store_having_personalised_panel unless @options[:has_personalised_panel].blank?
    distributions = distributions.for_store_having_generic_panel unless @options[:has_generic_panel].blank?
    distributions = distributions.for_distribution(@options[:distributor]) unless @options[:distributor].blank?
    distributions = distributions.for_ship_via(@options[:ship_via]) unless @options[:ship_via].blank?
    distributions = distributions.for_participation_only_stores if @options[:participation_only_stores]
    distributions.map {|d| DistributionRow.new(d, period, running_order) }.sort
  end

  def running_order
    @running_order ||= @options[:running_order].split ','
  end

  def include_fields
    includes = [{order: :store}, :address]
    includes << :postcode_sectors if require_postcode_table?
    includes << {order: {option: {values: [:page, :period]}}} if require_table?('Page') || require_table?('Period')
    includes << {order: :option} if require_option_table?
    includes << {order: {store: :client}} if require_table?('Client')
    includes << {order: {store: :address}} if require_address_table?
    includes << :publisher if require_publisher_address?
    includes
  end

  def require_address_table?
    require_table?('Delivery Address') || require_table?('Store Address')
  end

  def require_postcode_table?
    fields.any? {|f| f.match /Delivery Postcode/}
  end

  def require_option_table?
    require_table?('Option') || fields.any? {|f| f.match /Total Boxes/}
  end

  def require_publisher_address?
    fields.any? {|f| f.match /Publisher Address/}
  end

  def require_table?(name)
    export_tables.include?(name)
  end

  def export_tables
    @export_tables ||= fields.map {|f| f.split(/\-/)[0]}.uniq
  end

  def all_options
    Option.for_client(period.client_id).ordered
  end

  def selected_options
    Option.ordered.find(@options[:option])
  end

  def options
    @options[:option].blank? ? all_options : selected_options
  end

  def xls
    @spreadsheet ||= Spreadsheet::Workbook.new
  end

  def sheet_for_option(option)
    Sheet.new xls.create_worksheet(name: option.name), fields
  end
   
  def write_orders
    if @options[:split_options]
      write_orders_on_multiple_tabs
    else
      write_orders_on_one_tab
    end
  end

  def write_orders_on_one_tab
    sheet = Sheet.new xls.create_worksheet(name: 'Orders'), fields
    sheet.write_orders(all_distributions, period)
  end

  def write_orders_on_multiple_tabs
    options.each do |option|
      write_orders_for_option(option)
    end
    sheet_for_option(options.first) if xls.worksheets.empty? # handle no orders
  end

  def write_orders_for_option(option)
    orders = distributions_for_option(option)
    sheet_for_option(option).write_orders(orders, period, option) if orders.length > 0
  end

  def period
    @period ||= Period.find(@options[:period])
  end

  def file_name
    "#{export_template.name}-#{Time.now.strftime('%d%b%Y-%H%M')}.xls"
  end

  def fields
    @fields ||= export_template.value.split(',')
  end

  def export_template
    @export_template ||= ExportTemplate.find(@options[:template])
  end

  def export
    write_orders
    raw_data
  end

  def raw_data
    data = StringIO.new
    xls.write data
    data.string
  end

  class Sheet
    
    def initialize(sheet, fields)
      @sheet = sheet
      @fields = fields
      @totals = {}
    end

    def write_orders(orders, period, option = nil)
      write_sheet_title(period, option)
      write_header
      row = 2
      orders.each do |order|
        write_order_at(order, row)
        row += 1
      end
      write_totals_at(row)
      set_column_widths
    end

    private

    def set_column_widths
      return if @fields.empty?
      @fields[0].size.times do |col|
        @sheet.column(col).width = max_column_width(col) * 1.8
      end
    end

    def max_column_width(column)
      width = 2
      (2..@fields.length+2).each do |row|
        row_width = @sheet[row, column].to_s.length
        width = row_width > width ? row_width : width
      end
      width
    end

    def write_sheet_title(period, option)
      @sheet[0,0] = sheet_title(period, option)
      @sheet.row(0).height = 20
      @sheet.row(0).set_format 0, title_format
    end

    def sheet_title(period, option)
      title = "#{period.client.name} Period #{period.period_number} #{period.year}"
      title += " - Option: #{option.name}" if option
      title
    end

    def write_header
      @sheet.row(1).height = 20
      @fields.each_with_index do |value, col|
        @sheet[1, col] = value
        @sheet.row(1).set_format col, bold_format
      end
    end

    def write_totals_at(row)
      return if @totals.empty?
      set_value(row, 0, 'TOTAL')
      @totals.each do |col, value|
        @sheet[row, col] = value
        @sheet.row(row).set_format col, bold_format
      end
    end

    def title_format
      Spreadsheet::Format.new(left: nil, right: nil, top: nil, bottom: nil, font: Spreadsheet::Font.new("Arial", family: :swiss, weight: :bold, size: 14))
    end

    def bold_format
      Spreadsheet::Format.new(left: 'thin', right: 'thin', top: 'thin', bottom: 'thin', font: Spreadsheet::Font.new("Arial", family: :swiss, weight: :bold))
    end

    def write_order_at(order, row)
      @sheet.row(row).height = 20
      @fields.each_with_index do |field, col|
        value = order.value(field)
        set_value(row, col, value)
        add_value_at_column(value, col) if sum_value_for_field?(field)
      end
    end

    def sum_value_for_field?(field)
      field.include?('Total') || field.include?('Quantity')
    end

    def add_value_at_column(value, column)
      @totals[column] ||= 0
      @totals[column] += value.to_i
    end

    def set_value(row, col, value)
      @sheet[row, col] = value
      @sheet.row(row).set_format col, bordered_format
    end

    def bordered_format
      Spreadsheet::Format.new(left: 'thin', right: 'thin', top: 'thin', bottom: 'thin')
    end
  end

  class DistributionRow
    include Comparable

    def initialize(distribution, period, running_order)
      @distribution = distribution
      @period = period
      @position = running_order.index(my_running_order) || 1000
    end

    attr_accessor :distribution
    attr_reader :position
    delegate :order, to: :distribution
    delegate :store, to: :order

    def my_running_order
      if store.store_urgent? 
        "Store Urgents"
      elsif store.logo == 'BLANKS'
        "Blanks"
      else
        "#{distribution_type_name} #{distribution_week_running_order}"
      end
    end

    def distribution_week_running_order
      return "2 weeks prior" if distribution.distribution_week == -2
      return "week prior" if distribution.distribution_week == -1
      return "week after" if distribution.distribution_week == 1
      return "2 weeks after" if distribution.distribution_week == 2
      "week of promo"
    end

    def value(field)
      field = field.downcase
      obj_type = field.split(/\-/)[0]
      return publisher_address_value(field) if publisher_address_field?(field)
      return distribution_value(field) if obj_type == 'distribution'

      begin
        return case obj_type
          when 'order' then order
          when 'client' then order.store.client
          when 'option' then order.option
          when 'store' then order.store
          when 'page' then order.page
          when 'store address' then order.store.store_address
        end.send(translate_field_name(field))
      rescue
        return nil
      end
    end

    def translate_field_name(field)
      return :status_text if field == 'order-status'
      return :calculate_box_count if field == 'order-total boxes'
      field.split(/\-/)[1].gsub(/ /, '_').to_sym
    end

    def distribution_value(field)
      return distribution_address_value(field) if address_field?(field)

      field_name = translate_field_name(field)
      case field_name
        when :distribution_week then return distribution_week_running_order
        when :date_of_distribution then return distribution_week
        when :delivery_postcode then return delivery_postcode
        when :leaflet_number then return distribution_leaflet_number
        when :total_boxes then return distribution.calculate_box_count
        when :type then return distribution_type_name
        else return distribution.send(field_name)
      end
    end

    def publisher_address_field?(field)
      field =~ /publisher address/
    end

    def address_field?(field)
      field =~ /\-address/
    end

    def publisher_address_value(field)
      return nil if distribution.publisher.nil?
      distribution.publisher.send field.split(/publisher address\-/)[1].gsub(/ /, '_').to_sym
    end

    def distribution_address_value(field)
      return nil if distribution.address.nil?
      distribution.address.send field.split(/\-address /)[1].gsub(/ /, '_').to_sym
    end

    def distribution_type_name
      return 'In Store' if distribution.store_delivery?
      return 'Royal Mail' if distribution.royal_mail?
      return 'Newspaper' if distribution.newspaper?
      return 'Solus Team' if distribution.solus_team?
      return 'Store Own Dist' if distribution.store_own_delivery?
      'Unknown Distribution'
    end

    def distribution_week
      (@period.date_promo + (7 * distribution.distribution_week)).strftime('%d %B %Y')
    end

    def distribution_leaflet_number
      distribution.reference_number.blank? ? nil : "#{@period.week_number + distribution.distribution_week}/#{distribution.reference_number}"
    end

    def delivery_postcode
      distribution.postcode_sectors.map {|s| s.to_s}.join(', ')
    end

    def <=>(row)
      return royal_mail_sequence(row) if same_royal_mail_week?(row)
      position <=> row.position
    end

    def same_royal_mail_week?(row)
      distribution.royal_mail? && row.distribution.royal_mail? && distribution.distribution_week == row.distribution.distribution_week
    end

    def royal_mail_sequence(row)
      business_name <=> row.business_name
    end

    def business_name
      distribution.address ? (distribution.address.business_name || '') : ''
    end
  end
end