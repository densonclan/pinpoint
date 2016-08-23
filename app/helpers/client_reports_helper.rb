module ClientReportsHelper

  def largest_order_for(client)
    @largest_orders ||= {}
    @largest_orders[client.id] ||= client.orders.largest
  end

  def smallest_order_for(client)
    @smallest_orders ||= {}
    @smallest_orders[client.id] ||= client.orders.smallest
  end

  def current_orders_count(client)
    client.current_orders.count
  end

  def order_count_for_client(client)
    return [] if client.periods.empty?

    client.periods.ordered.pluck(:period_number).uniq.map do |period_number|
      [period_number, report_client_period_count(client, period_number)]
    end
  end

  def report_client_period_count(client, period_number)
    period = client.period period_number
    period ? (client_orders_per_period[period.id] || 0) : 0
  end

  def client_orders_per_period
    @period_counts ||= calculate_orders_per_period
  end

  def calculate_orders_per_period
    period_counts = {}
    Order.accessible_by(current_user).count_by_period.each do |o|
      period_counts[o.period_id] = o.total_quantity
    end
    period_counts
  end

  def client_chart_div(client)
    "orders_chart_#{client.id}"
  end
end