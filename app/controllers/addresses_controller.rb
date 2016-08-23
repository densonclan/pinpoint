class AddressesController < ApplicationController

  before_filter :require_write_access, only: [:new, :create, :edit, :update, :destroy]

  def index
    @addresses = Address.ordered.page(params[:page])
  end

  def advanced
    @addresses = Address.filter(params[:address_type]).paginate :page => params[:page]
    render :index
  end

  def show
    render json: Address.accessible_by(current_user).find(params[:id]).to_json
  end

  def search
    @addresses = Address.search(params[:query],params[:page])
    render :index
  end

  def lookup
    render json: Address.of_type(params[:type]).search(params[:term]).limit(20)
  end

  def new
    @address = Address.new
    if params[:store_id]
      @store = Store.find params[:store_id]
      @address.store_id = @store.id
    end
    if params[:distribution_id]
      @distribution = Distribution.find params[:distribution_id]
      @address.distribution_id = @distribution.id
    end
  end

  def create
    @address = AddressManager.new(current_user).create(params[:address])
    if @address.persisted?
      redirect_to redirect_path_after_save, notice: 'Address has been saved'
    else
      render :new
    end
  end

  def edit
    @address = Address.accessible_by(current_user).find(params[:id])
  end

  def update
    @address = AddressManager.new(current_user).update(params[:id], params[:address])
    if @address.valid?
      redirect_to redirect_path_after_save, notice: 'Changes have been saved'
    else
      render :edit
    end
  end

  def destroy
    address = Address.accessible_by(current_user).find(params[:id])
    address.destroy
    redirect_to params[:redirect] == 's' ? store_path(address.store_id) : addresses_path, notice: 'Address has been deleted.'
  end

  private
  


  def redirect_path_after_save
    if params[:address][:store_id]
      return store_path(params[:address][:store_id])
    elsif params[:address][:distribution_id]
      distribution = Distribution.find params[:address][:distribution_id]
      return order_path(distribution.order_id)
    end
    return addresses_path
  end
end