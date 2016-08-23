require 'spreadsheet'

class OrderExporter

  def initialize(user, options)
    @user = user
    @options = options
  end

  def orders_for_option(option)
    query_and_map_orders Order.for_option(option.id)
  end

  def all_orders
    query_and_map_orders @options[:option].blank? ? Order.where(nil) : Order.for_option(@options[:option])
  end

  def query_and_map_orders(orders)
    orders = orders.includes(include_fields).for_period(@options[:period])
    orders = orders.for_distribution(@options[:distributor]) unless @options[:distributor].blank?
    orders = orders.for_ship_via(@options[:ship_via]) unless @options[:ship_via].blank?
    orders = orders.for_participation_only_stores if @options[:participation_only_stores]
    orders.map {|o| OrderRow.new(o, period) }.sort
  end

  def include_fields
    includes = [:distributions] # distributions are always required (for sorting)
    includes << {distributions: :postcode_sectors} if require_postcode_table?
    if require_table?('Page') || require_table?('Period')
      includes << {option: {values: [:page, :period]}}
    elsif require_table?('Option')
      includes << :option
    end
    if require_table?('Client')
      includes << {store: :client}
    elsif require_table?('Store')
      includes << :store
    end
    includes << {store: :address} if require_address_table?
    includes
  end

  def require_address_table?
    require_table?('Delivery Address') || require_table?('Store Address')
  end

  def require_postcode_table?
    fields.any? {|f| f.match /Delivery Postcode/}
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
    ExcelSheet.new xls.create_worksheet(name: option.name), fields
  end
   
  def write_orders
    if @options[:split_options]
      write_orders_on_multiple_tabs
    else
      write_orders_on_one_tab
    end
  end

  def write_orders_on_one_tab
    sheet = ExcelSheet.new xls.create_worksheet(name: 'Orders'), fields
    sheet.write_orders(all_orders, period)
  end

  def write_orders_on_multiple_tabs
    options.each do |option|
      write_orders_for_option(option)
    end
    sheet_for_option(options.first) if xls.worksheets.empty? # handle no orders
  end

  def write_orders_for_option(option)
    orders = orders_for_option(option)
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

  class OrderRow
    include Comparable

    def initialize(order, period)
      @order = order
      @period = period
    end

    attr_accessor :order
    delegate :store, :distributions, to: :order

    def value(field)
      field = field.downcase
      return distribution_value(field) if distribution_field?(field)

      begin
        return case field.split(/\-/)[0]
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
      distribution = distribution_matching(field)
      return nil unless distribution

      return distribution_address_value(distribution, field) if address_field?(field)

      field_name = translate_field_name(field)
      case field_name
        when :distribution_week then return distribution_week(distribution)
        when :date_of_distribution then return distribution_week(distribution)
        when :delivery_postcode then return delivery_postcode(distribution)
        when :leaflet_number then return distribution_leaflet_number(distribution)
        when :total_boxes then return distribution.calculate_box_count
        else return distribution.send(field_name)
      end
    end

    def distribution_field?(field)
      distribution_matching(field) != nil
    end

    def address_field?(field)
      field =~ /\-address/
    end

    def distribution_address_value(distribution, field)
      return nil if distribution.address.nil?
      distribution.address.send field.split(/\-address /)[1].gsub(/ /, '_').to_sym
    end

    def distribution_matching(field)
      return newspaper if field.match 'newspaper'
      return royal_mail if field.match 'royal mail'
      return store_delivery if field.match 'store delivery'
      return solus_team if field.match 'solus team'
      nil
    end

    def distribution_week(distribution)
      (@period.date_promo + (7 * distribution.distribution_week)).strftime('%d %B %Y')
    end

    def distribution_leaflet_number(distribution)
      distribution.reference_number.blank? ? nil : "#{@period.week_number + distribution.distribution_week}/#{distribution.reference_number}"
    end

    def delivery_postcode(distribution)
      distribution.postcode_sectors.map {|s| s.to_s}.join(', ')
    end

    def <=>(row)
      (store.running_order || 10) <=> (row.store.running_order || 10)
    end
   
    %w(newspaper royal_mail solus_team store_delivery).each do |meth|
      define_method(meth) { distributions.select {|d| d.send("#{meth}?")}.first }
    end
  end
end