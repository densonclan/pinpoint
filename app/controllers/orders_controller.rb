class OrdersController < ApplicationController
  helper_method :sort_column, :sort_direction

  before_filter :require_write_access, only: [:new, :create, :edit, :update, :destroy, :update_status, :update_orders, :copy]

  def index
    @orders = apply_filter.accessible_by(current_user).for_listing.order_by(params[:sort], params[:direction]).page(params[:page])
  end

  def search
    @orders = Order.accessible_by(current_user).search(params[:query]).page params[:page]
  end

  def advanced
    @orders = Order.filter(params, current_user).for_listing.page(params[:page])
    render :index
  end

  def show
    @order = Order.accessible_by(current_user).includes(:store => :address).find(params[:id])
  end

  def notes
    @order = Order.accessible_by(current_user).find(params[:id])
    @comments = @order.comments.ordered.page params[:page]
  end

  def new
    @order = Order.new(account_number: params[:account])
    @order.store = Store.find_by_account_number(params[:account]) unless params[:account].blank?
    @order.option = @order.store.preferred_option if @order.store
    prepare_form
  end

  def create
    @order = OrderCreator.new(current_user, params[:order]).perform
    if @order.persisted?
      redirect_to @order, notice: "Order has been created"
    else
      prepare_form
      flash[:error] = "Could not save the order"
      render :new
    end
  end

  def copy
    @order = OrderAccessor.new(current_user).copy_order_with_id(params[:id])
    prepare_form
    render :new
  end

  def edit
    @order = Order.accessible_by(current_user).find(params[:id])
    prepare_form
  end

  def update
    if @order = OrderUpdator.new(current_user, params[:id], params[:order]).perform
      flash[:error] = 'Could not save changes'
      prepare_form
      render :edit
    else
      redirect_to order_path(params[:id]), notice: 'Changes have been saved'
    end
  end

  def destroy
    @order = OrderDestroyer.new(current_user, params[:id]).perform
    if @order.destroyed?
      redirect_to orders_path, notice: 'Order deleted successfully'
    else
      prepare_form
      render :edit
    end
  end

  def update_status
    @option = Option.accessible_by(current_user)
    @option = params[:order_option] ? @option.find(params[:order_option]) : @option.first
    @orders = Order.accessible_by(current_user).for_listing.for_current_period.for_option(@option.id).page(params[:page])
  end

  #
  # Update status POST
  #
  def update_orders
    if params[:order_status] && params[:order_option]
      option = Option.accessible_by(current_user).find(params[:order_option])
      Order.update_status_for_option(option, params[:order_status])
      flash[:notice] = "Status for orders has been updated."
      redirect_to orders_path
    end
  end

  private

  def apply_filter
    case params[:type]
      when 'all' then return Order.where('1=1')
      when 'previous' then return Order.for_previous_period(current_user)
      when 'next' then return Order.for_next_period(current_user)
      when 'duplicated' then return Order.duplicates
      else return Order.for_current_period
    end
  end

  def prepare_form
    (Distributor.count - @order.distributions.length).times do
      @order.distributions.build
    end
    @order.comments.build unless @order.comments.any? {|c| c.new_record?}
  end    

  def sort_column
    params[:sort] ||= 'orders.updated_at'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end
end
