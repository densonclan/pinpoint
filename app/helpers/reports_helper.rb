module ReportsHelper

  def current_period
    @current_period ||= Period.accessible_by(current_user).all_current.first.decorate(context: {user: current_user})
  end

  def total_order_count
    number_with_delimiter Order.accessible_by(current_user).count
  end

  def completed_order_count
    number_with_delimiter Order.accessible_by(current_user).completed.count
  end

  def total_leaflets_count
    number_with_delimiter Order.accessible_by(current_user).count_leaflets
  end

  def largest_order
    @largest_order ||= Order.accessible_by(current_user).largest
  end

  def smallest_order
    @smallest_order ||= Order.accessible_by(current_user).smallest
  end

  def store_with_most_orders
    @store_with_most_orders ||= Store.accessible_by(current_user).with_most_orders
  end

  def report_menu_class(item)
    store_and_stores_path?(item) || bm_and_bms_path?(item) || item.to_s == params[:action] ? 'active' : nil
  end

  def bm_and_bms_path?(item)
    item == :business_managers && params[:action] == 'business_manager'
  end

  def store_and_stores_path?(item)
    item == :stores && report_store_menu?
  end

  def report_store_menu?
    params[:action] == 'store'
  end
end