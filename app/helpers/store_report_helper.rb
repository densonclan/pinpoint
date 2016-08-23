module StoreReportHelper

  %w(period page option distributor).each do |m|
    define_method("orders_for_#{m}_count") {|v| display_report_map_reduce eval("orders_for_#{m}(v)"), :order_count }
    define_method("orders_for_#{m}_box_count") {|v| display_report_map_reduce eval("orders_for_#{m}(v)"), :total_boxes }
    define_method("orders_for_#{m}_leaflet_count") {|v| display_report_map_reduce eval("orders_for_#{m}(v)"), :total_quantity }
    define_method("#{m}s_with_orders") { eval("#{m}s").select {|o| eval("orders_for_#{m}(o)").length > 0} } # e.g. options.select {|o| orders_for_option(o).length > 0 }
  end

  def display_report_map_reduce(collection, method)
    number_with_delimiter report_map_reduce(collection, method)
  end
  
  def report_map_reduce(collection, method)
    collection.map {|i| i.send(method)}.reduce(:+) || 0
  end

  %w(period option).each do |m|
    define_method("orders_for_#{m}") {|v|
      @orders.select {|o| eval("o.#{m}_id") == v.id}
    }
  end

  def orders_for_page(page)
    @orders_for_page ||= {}
    @orders_for_page[page.id] ||= @orders.select {|o| o.option.page.id == page.id}
  end

  def orders_for_distributor(distributor)
    @distribution_counts.select {|d| d.distributor_id == distributor.id}
  end  

  def options_for_client_options(client)
    options_from_collection_for_select options_for_client(client), :id, :name, params[:order_option]
  end

  def options_for_client(client)
    @options_for_client ||= Option.for_client(client.id).ordered
  end

  def periods_for_client_options(client)
    options_from_collection_for_select periods_for_client(client).decorate, :id, :to_s, params[:order_period]
  end

  def periods_for_client(client)
    @periods_for_client ||= Period.for_client(client.id).ordered
  end

  def non_empty(collection)
    collection.select {|o| eval("orders_for_#{o.class.name.downcase}(o)").length > 0 }
  end
end