class OrderDestroyer < OrderAccessor

  def initialize(user, order_id)
    super(user)
    @order = lookup_order_with_id(order_id)
  end

  def perform
    return @order unless check_has_lock
    @order.destroy
    @order
  end
end