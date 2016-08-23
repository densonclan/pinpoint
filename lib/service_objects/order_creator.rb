class OrderCreator < OrderAccessor

  def initialize(user, attributes)
    super(user)
    @attributes = attributes
  end

  def perform
    @order = build_order
    @order.save
    @order
  end

  private

  def build_order
    @order = Order.new(@attributes)
    @order.user = @user
    @order.updated_by = @user
    @order.comments.each {|c| c.user = @user}
    lookup_store
    count_quantities
    @order.status = Order::AWAITING_PRINT unless @order.status
    @order
  end
end