class OrderAccessor

  def initialize(user, order = nil)
    @user = user
    @order = order if order
  end

  def copy_order_with_id(id)
    @order = lookup_order_with_id(id)
    order = clone_order
    order.account_number = order.store.account_number
    order
  end

  def clone_order
    order = @order.dup
    order.status = Order::AWAITING_PRINT
    clone_distributions_on_order(order)
    order.comments = @order.comments.map {|c| order.comments.build(full_text: c.full_text, user_id: c.user_id) }
    order
  end

  protected

  def lookup_store
    if !@order.account_number.blank? && @user
      @order.store = Store.accessible_by(@user).find_by_account_number(@order.account_number)
      @order.errors.add(:store_id, "account number invalid '#{@order.account_number}'") unless @order.store
    end
  end

  def count_quantities
    @order.total_quantity = @order.distributions.map {|d| d.total_quantity || 0}.reduce(:+)
  end

  def check_has_lock
    if @order.lock
      if @order.lock.user != @user
        @order.errors.add(:base, "The lock on this store is held by #{@order.lock.user.name}")
        return false
      end
    else
      @order.errors.add(:base, 'This record is not locked')
      return false
    end
    true
  end

  def lookup_order_with_id(id)
    Order.accessible_by(@user).find(id)
  end

  def clone_distributions_on_order(order)
    @order.distributions.each do |d|
      clone_distribution_to_order(d, order)
    end
  end

  def clone_distribution_to_order(distribution, order)
    d = order.distributions.build clone_distribution_attributes(distribution)
    d.postcode_ids = distribution.distribution_postcodes.map {|dp| dp.postcode_sector_id}.join(',')
  end

  CLONE_DISTRIBUTION_ATTRIBUTES = %w(total_quantity notes contract_number reference_number distributor_id distribution_week ship_via address_id publisher_id)

  def clone_distribution_attributes(distribution)
    distribution.attributes.select {|k,v| CLONE_DISTRIBUTION_ATTRIBUTES.include?(k) }
  end
end