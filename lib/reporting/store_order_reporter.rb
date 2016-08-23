class StoreOrderReporter < OrderQuantityReporter

  attr_accessor :store

  def initialize(store, user, params)
    super(user, params)
    self.store = store
  end

  def last_order_period
    return nil if empty?
    store.orders.latest.period.period_number
  end

  def orders_per_period
    (total_orders_count.to_f / periods.length).round(2)
  end

  def orders_average_total
    return 0 if empty?
    (report_map_reduce(orders, :total_quantity).to_f / total_orders_count.to_f).round
  end

  def orders_average_boxes
    return 0 if empty?
    (report_map_reduce(orders, :total_boxes).to_f / total_orders_count.to_f).round(1)
  end

  def pages_with_counts
    @page_counts.values.map {|p| p.page}
  end

  def orders_for_page_count(page)
    number_with_delimiter @page_counts[page.id].count
  end

  def orders_for_page_leaflet_count(page)
    number_with_delimiter @page_counts[page.id].total_quantity
  end

  def orders_for_page_box_count(page)
    number_with_delimiter @page_counts[page.id].total_boxes
  end

  # overrides superclass
  def fetch_orders
    Order.for_store(store.id).filter(@params, @user)
  end

  # overrides superclass
  def fetch_distributions
    Distribution.for_store(store.id).includes(:order).filter(@params, @user)
  end

  # overrides superclass
  def add_order(order)
    page = page_for_order(order)
    order_report_for_order(order).add_item(order, page)
    page_report_for_page(page).add_item(order, page) if page
    puts "PAGE NOT FOUND FOR ORDER #{order.id}" if !page
  end

  def page_report_for_page(page)
    @page_counts ||= {}
    @page_counts[page.id] ||= PageCount.new(page)
  end
end