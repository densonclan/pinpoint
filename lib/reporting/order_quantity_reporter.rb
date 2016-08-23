class OrderQuantityReporter

  include ActionView::Helpers::NumberHelper

  def initialize(user, params)
    @params = params
    @user = user
    @params[:order_period] = periods.map {|p|p.id}    
  end

  def period_names
    periods.map {|p| "#{p.client.name}: #{p.period_number.to_s}" }.join(", ")
  end

  def periods
    @periods ||= lookup_periods
  end

  def empty?
    total_orders_count == 0
  end

  def orders_count
    number_with_delimiter total_orders_count
  end

  def leaflet_count
    display_report_map_reduce orders, :total_quantity
  end

  def total_boxes
    display_report_map_reduce orders, :total_boxes
  end


  def options_with_orders
    Option.for_listing.where(id: unique_option_ids).ordered.decorate(context: {user: @user})
  end

  def distributors_with_orders
    Distributor.where(id: unique_distributor_ids).ordered
  end

  def orders_for_option_count(option)
    display_report_map_reduce(orders_with_option(option.id), :count)
  end

  def orders_for_option_box_count(option)
    display_report_map_reduce(orders_with_option(option.id), :total_boxes)
  end

  def orders_for_option_leaflet_count(option)
    display_report_map_reduce(orders_with_option(option.id), :total_quantity)
  end

  def orders_for_distributor_count(distributor)
    number_with_delimiter report_for_distribution(distributor.id).count
  end

  def orders_for_distributor_box_count(distributor)
    number_with_delimiter report_for_distribution(distributor.id).total_boxes
  end

  def orders_for_distributor_leaflet_count(distributor)
    number_with_delimiter report_for_distribution(distributor.id).total_quantity
  end

  protected

  def lookup_periods
    periods = Period.with_client.accessible_by(@user)
    @params[:order_period].blank? ? periods.all_current : periods.find(@params[:order_period])
  end    

  def orders_with_option(option_id)
    orders.select {|r| r.option_id == option_id}
  end

  def unique_distributor_ids
    distributions.map {|d| d.distributor_id}
  end

  def unique_option_ids
    orders.map{|o| o.option_id}.uniq
  end

  def total_orders_count
    @total_orders_count ||= report_map_reduce orders, :count
  end

  def percentage_of_orders(count)
    return 0 if total_orders_count.zero?
    (100 * count.to_f / total_orders_count.to_f).floor
  end  

  def order_count_with_status(status_name)
    (orders_with_status(status_name).map {|row| row.count}.reduce :+) || 0
  end

  def orders_with_status(status_name)
    status = eval("Order::#{status_name.upcase}")
    orders.select {|report| report.status == status }
  end

  def display_report_map_reduce(collection, method)
    number_with_delimiter report_map_reduce(collection, method)
  end
  
  def report_map_reduce(collection, method)
    collection.map {|i| i.send(method)}.reduce(:+) || 0
  end

  def orders
    @orders ||= fetch_and_add_orders || []
  end

  def fetch_and_add_orders
    fetch_orders.each {|order| add_order(order) }
    @orders
  end

  # overridden in subclass
  def fetch_orders
    Order.filter(@params, @user)
  end

  def add_order(order)
    order_report_for_order(order).add_item(order, page_for_order(order))
  end

  def order_report_for_order(order)
    @orders ||= []
    order_count_for_order(order) || add_order_count_for_order(order)
  end

  def add_order_count_for_order(order)
    count = OrderCount.new(order.status, order.option_id)
    @orders << count
    count
  end

  def order_count_for_order(order)
    @orders.select {|count| count.status == order.status && count.option_id == order.option_id }.first
  end

  def page_for_order(order)
    return nil if order.nil? || pages[order.period_id].nil?
    pages[order.period_id][order.option_id]
  end

  def pages
    @pages ||= fetch_and_convert_pages
  end

  def fetch_and_convert_pages
    hash = {}
    fetch_option_values.each do |option_value|
      hash[option_value.period_id] ||= {}
      hash[option_value.period_id][option_value.option_id] = option_value.page
    end
    hash
  end

  def fetch_option_values
    OptionValue.includes(:page)
  end

  def distributions
    @distributions ||= fetch_and_add_distributions
  end

  def fetch_and_add_distributions
    fetch_distributions.each {|distribution| add_distribution(distribution) }
    @distributions
  end

  def fetch_distributions
    Distribution.includes(:order).filter(@params, @user)
  end

  def add_distribution(distribution)
    report_for_distribution(distribution.distributor_id).add_item(distribution, page_for_order(distribution.order))
  end

  def report_for_distribution(distributor_id)
    @distributions ||= []
    report = @distributions.select {|d| d.distributor_id == distributor_id}.first
    if !report
      report = DistributionCount.new(distributor_id)
      @distributions << report
    end
    report
  end
end