class PeriodCompiler

  def initialize(user_id, period_id)
    @user_id = user_id
    @period_id = period_id
  end

  def perform
    lookup_user_and_period
    return if !@period.current || @period.locked
    lock_period!
    copy_orders_to_next_period
    set_period_completed!
    Store.reset_personalised_panel
  end

  private

  def lookup_user_and_period
    @user = User.find(@user_id)
    @period = Period.find(@period_id)
  end    

  def copy_orders_to_next_period
    orders_to_clone_to.each {|o| clone_order_to_next_period(o) }
  end

  def clone_order_to_next_period(order)
    new_order = OrderAccessor.new(@user, order).clone_order
    new_order.updated_by = @user
    new_order.period = @period.next_period
    new_order.save
  end  

  def orders_to_clone_to
    @period.orders.with_distributions.select {|o| should_clone_order?(o) }
  end

  def should_clone_order?(order)
    !exception_ids.include?(order.id) && !existing_order_store_ids.include?(order.store_id)
  end

  def exception_ids
    @exception_ids ||= OrderException.where(period_id: @period.next_period.id).map {|o| o.order_id}
  end

  def existing_order_store_ids
    @existing_order_store_ids ||= @period.next_period.orders.map {|o| o.store_id }
  end

  def lock_period!
    @period.locked = true
    @period.save
  end

  def set_period_completed!
    @period.completed = true
    @period.current = false
    @period.locked = false
    @period.save
    set_next_period_current!
  end

  def set_next_period_current!
    @period.next_period.current = true
    @period.next_period.save
  end
end
