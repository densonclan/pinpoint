class PeriodsController < ApplicationController

  before_filter :require_write_access, only: [:clients]
  helper_method :sort_column, :sort_direction

  def index
    @clients = Client.accessible_by(current_ability).ordered
    @periods = Period.ordered
  end

  def review
    @period = Period.find(params[:id])
    if request.xhr?
      @period_new = @period.next_period
      if params[:store_page]
        params[:sort] = 'stores.updated_at' if params[:sort] == 'orders.updated_at'
        @non_order_stores = Store.for_client(@period.client_id).without_orders_in_periods(@period, @period_new).order_by(params[:sort], params[:direction]).page(params[:store_page])
        render partial: 'stores_table'
      else
        @orders = @period.orders.for_review_list.order_by(params[:sort], params[:direction]).search(params[:search], params[:page])
        render partial: 'orders_table'
      end
    else 
      if @period.current
        @period_new = @period.next_period
        @orders = @period.orders.for_review_list.ordered.page(1)
        @orders_having_part_box = @period.orders.select {|o| o.having_part_box? }
        @orders_without_logo = @period.orders.for_store_without_logo
        @non_order_stores = Store.for_client(@period.client_id).without_orders_in_periods(@period, @period_new).ordered.page(1)
      else
        flash[:error] = "Cannot review non-current periods."
        redirect_to periods_path
      end
    end
  end

  def compile
    PeriodCompiler.new(current_user.id, params[:id]).delay.perform
    redirect_to periods_path, notice: "Period has been queued for compilation and will be completed within a few seconds"
  end

  def new
    @period = Period.new
  end

  def create
    @period = Period.new(params[:period])
    if @period.save
      redirect_to periods_path, notice: 'Period saved successfully'
    else
      flash[:error] = "Error saving period"
      render :new
    end
  end

  def edit
    @period = Period.find(params[:id])
  end

  def update
    @period = Period.find(params[:id])

    if @period.update_attributes(params[:period])
      redirect_to periods_path, notice: 'Period saved successfully'
    else
      flash[:error] = "Error saving period"
      render :action => 'edit'
    end
  end

  def destroy
    Period.find(params[:id]).destroy
    redirect_to periods_path, notice: 'Period deleted successfully'
  end

  def sort_column
    params[:sort] ||= 'orders.updated_at'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end

end