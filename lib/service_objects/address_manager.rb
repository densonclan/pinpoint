class AddressManager

  def initialize(user)
    @user = user
  end

  def create(params)
    @address = Address.new
    populate_address params
    @address
  end

  def update(id, params)
    @address = Address.accessible_by(@user).find id
    populate_address params
    @address
  end

  def populate_address(params)
    @address.updated_by = @user
    @address.attributes = params
    if @address.save
      set_address_on_distribution params[:distribution_id], !params[:publisher].blank?
      set_address_on_store params[:store_id]
    end
  end

  def set_address_on_store(store_id)
    if store_id
      store = Store.find store_id
      store.address_id = @address.id
      store.save
    end
  end

  def set_address_on_distribution(distribution_id, is_publisher)
    if distribution_id
      distribution = Distribution.find distribution_id
      if is_publisher
        distribution.publisher_id = @address.id
      else
        distribution.address_id = @address.id
      end
      distribution.save
    end
  end
end