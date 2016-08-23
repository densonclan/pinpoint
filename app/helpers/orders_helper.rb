module OrdersHelper

  def total_quantities_for_orders(orders)
    orders.map {|o| o.total_quantity }.reduce :+
  end

  def sum_order_distribution_total_quantities(order)
    (order.distributions.map {|d| d.total_quantity || 0}.reduce :+) || 0
  end

  def sum_order_distribution_total_boxes(order)
    (order.distributions.map {|d| distribution_total_boxes(d, order.page)}.reduce :+) || 0
  end

  def order_menu_class(tab)
    tab == params[:action] ? 'active' : nil
  end

  def order_tab_class(tab)
    update_tab_selected?(tab) || ((params[:action] == 'index' && tab == 'index' &&  params[:type] == nil) || tab == params[:type]) ? 'active' : nil
  end

  def update_tab_selected?(tab)
    (tab == 'update_status' && params[:action] == 'update_status')
  end

  def order_total_boxes(order)
    if order.option && page = order.option.page_for_period(order.period_id)
      boxes = (order.total_quantity.to_f / page.box_quantity.to_f).ceil
      "#{boxes} - (Total: #{order.total_quantity} Box quantity: #{page.box_quantity})"
    else
      "1 - (Total: #{order.total_quantity} Box quantity: unknown)"
    end
  end

  def box_quantity(order)
    order.option && order.option.page ? order.option.page.box_quantity : '-'
  end

  def order_status_options
    options_for_select [['Awaiting Print',0],['In Print',2],['Dispached',3],['Completed',1]], params[:order_status]
  end

  def order_period_options(selected = nil)
    options_for_select period_options.map {|d| [d.name, d.id]}, selected || params[:order_period]
  end


  def ship_via_options    
    [Distribution::SHIP_VIA_NEP, Distribution::SHIP_VIA_GH, Distribution::SHIP_VIA_STORE]
  end

  def show_advanced_filter?
    params[:action] == 'advanced'
  end

  def period_options_for_order(order)
    if order.store
      periods.for_client(order.store.client_id).includes(:client).decorate(context: {user: current_user})
    else
      periods.includes(:client).decorate(context: {user: current_user})
    end
  end

  def options_for_order(order)
    order.store ? Option.for_listing.for_client(order.store.client_id).accessible_by(current_user).ordered.decorate(context: {user: current_user}) : options
  end

  def postcode_sector_names(distribution)
    distribution.postcode_sectors.empty? ? 'none' : distribution.postcode_sectors.map {|p| p.to_s}.join(', ')
  end

  def postcode_sector_names_by_id(postcode_ids)
    postcode_ids.empty? ? 'none' : PostcodeSector.where("id in (?)", postcode_ids.split(',')).map {|p| p.to_s}.join(', ')
  end

  def postcode_sector_ids(distribution)
    distribution.postcode_sectors.map {|p| p.id}.join(',')
  end

  def page_title
    case params[:type]
      when 'all' then return 'All Orders'
      when 'previous' then return "Previous Period's Orders"
      when 'next' then return "Next Period's Orders"
      when 'duplicated' then return "Duplicated Orders"
      else return 'Orders'
    end
  end  
end