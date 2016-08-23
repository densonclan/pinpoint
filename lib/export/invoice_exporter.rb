require 'spreadsheet'

class InvoiceExporter

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
    distributions = distributions.includes([{order: :store}, :address]).for_period(@options[:period])
    distributions = distributions.for_ship_via(@options[:ship_via]) unless @options[:ship_via].blank?
    distributions = distributions.for_participation_only_stores if @options[:participation_only_stores]
    distributions_by_store = distributions.group_by {|d| d.order.store.id}.values
    distributions_by_store.map {|dists| StoreRow.new(dists, period) }.sort
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
    @period ||= Period.find_by_id(@options[:period])
  end

  def file_name
    "#{period.client.name} ##{period.period_number} #{period.year}-#{Time.now.strftime('%d%b%Y-%H%M')}.xls"
  end

  def fields
    #@fields ||= ['Store-Account Number', 'REF', 'Order-Total Quantity', 'Option-Name', 'Total royal mail', 'Total solus', 'Total newspaper', 'Total store delivery', 'PRINT CHARGE', 'DISTRIBUTION CHARGE']
    @fields ||= ['Store-Account Number', 'Order-Total Quantity', 'Option-Name', 'Total royal mail', 'Total solus', 'Total newspaper', 'Total store delivery', 'PRINT CHARGE', 'DISTRIBUTION CHARGE']
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

  class StoreRow
    include Comparable
    attr_accessor :distributions, :store

    def initialize(distributions, period)
      @distributions = distributions
      @period = period
      @store = distributions.first.order.store
    end

    def value(field)
      total_quantity = distributions.first.order.total_quantity
      return store.account_number if field == 'Store-Account Number'
      return store.reference_number if field == 'REF'
      return total_quantity if field == 'Order-Total Quantity'
      return distributions.map(&:order).map(&:option).map(&:name).uniq.join(', ') if field == 'Option-Name'
      return distributions_for(Distribution::ROYAL_MAIL).sum(&:total_quantity) if field == 'Total royal mail'
      return distributions_for(Distribution::SOLUS_TEAM).sum(&:total_quantity) if field == 'Total solus'
      return distributions_for(Distribution::NEWSPAPER).sum(&:total_quantity) if field == 'Total newspaper'
      return distributions_for(Distribution::IN_STORE).sum(&:total_quantity) if field == 'Total store delivery'
      return print_charge(total_quantity) if field == 'PRINT CHARGE'
      return distribution_charge if field == 'DISTRIBUTION CHARGE'
    end

    def <=>(row)
      store.account_number <=> row.store.account_number
    end

    def print_charge total_quantity

      return (total_quantity.to_f * 45/1000).round(2)
    end

    def distribution_charge
      total_royal_mail = distributions_for(Distribution::ROYAL_MAIL).sum(&:total_quantity)
      total_solus = distributions_for(Distribution::SOLUS_TEAM).sum(&:total_quantity)
      total_newspaper = distributions_for(Distribution::NEWSPAPER).sum(&:total_quantity)
      ((total_royal_mail.to_f * 45/1000) + (total_solus.to_f * 35/1000) + (total_newspaper.to_f * 25/1000)).round(2)
    end

    private
    def distributions_for distributor_id
      distributions.select {|d| d.distributor_id == distributor_id }
    end
  end
end
