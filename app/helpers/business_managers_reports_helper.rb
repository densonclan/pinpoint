module BusinessManagersReportsHelper

  def business_manager_names
    total_orders_for_managers.map {|m| m[:name] }
  end

  def order_count_for_business_manager
    client = @business_manager.client
    client.periods.ordered.pluck(:period_number).uniq.map do |period_number|
      [period_number, business_manager_period_count(period_number)]
    end
  end

  def business_manager_period_count(period_number)
    period = @business_manager.client.period period_number
    period ? (bm_orders_per_period[period.id] || 0) : 0
  end

  def bm_orders_per_period
    @period_counts ||= calculate_bm_orders_per_period
  end

  def calculate_bm_orders_per_period
    period_counts = {}
    Order.accessible_by(current_user).for_manager(@business_manager.id).count_by_period.each do |o|
      period_counts[o.period_id] = o.total_quantity
    end
    period_counts
  end

  def total_orders_for_managers
    @total_orders_for_managers ||= @business_managers.map {|m| {name: m.name, color: business_manager_color(m), y: manager_order_count(m)}}.reject {|m| m[:y].nil?}
  end

  def business_manager_color(bm)
    case bm.client_id
      when 1 then return '#00FF00'
      when 2 then return '#00FFFF'
      when 3 then return '#FFFF00'
      when 4 then return '#FF00FF'
      when 5 then return '#FFFF00'
      else return '#000000'
    end
  end

  def manager_order_count(manager)
    order = manager_order_counts.select {|o| o.id == manager.id}.first
    order ? order.total_quantity : nil
  end

  def manager_order_counts
    @manager_order_counts ||= Order.accessible_by(current_user).count_by_manager
  end

  def business_manager_stores
    number_with_delimiter Store.for_business_manager(@business_manager.id).count
  end

  def business_manager_orders
    number_with_delimiter Order.for_manager(@business_manager.id).count
  end

  def business_manager_completed_orders
    number_with_delimiter Order.for_manager(@business_manager.id).completed.count
  end

  def largest_business_manager_order_size
    return '-' unless largest_business_manager_order
    number_with_delimiter largest_business_manager_order.total_quantity
  end

  def largest_business_manager_order
    @largest_business_manager_order ||= Order.for_manager(@business_manager.id).largest
  end

  def smallest_business_manager_order_size
    return '-' unless smallest_business_manager_order
    number_with_delimiter smallest_business_manager_order.total_quantity
  end

  def smallest_business_manager_order
    @smallest_business_manager_order ||= Order.for_manager(@business_manager.id).smallest
  end
end
