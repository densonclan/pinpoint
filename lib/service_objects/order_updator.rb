class OrderUpdator < OrderAccessor

  def initialize(user, order_id, attributes)
    super(user)
    @attributes = attributes
    @order = lookup_order_with_id(order_id)
  end

  def perform
    cloning = should_clone_order?
    if cloning
      @order.lock.destroy if @order.lock
      @order = clone_order
    end
    @order.attributes = @attributes
    return @order if !cloning && !check_has_lock
    @order.comments.each {|c| c.user = @user if c.new_record? }
    @order.updated_by = @user
    count_quantities
    success = @order.save
    @order.lock.destroy if @order.lock && success
    success ? nil : @order
  end

  protected

  def clone_order
    @attributes.delete('distributions_attributes')
    @attributes.delete('comments_attributes')
    super
  end

  private

  def should_clone_order?
    !@attributes['period_id'].blank? && @attributes['period_id'].to_i != @order.period_id
  end
end