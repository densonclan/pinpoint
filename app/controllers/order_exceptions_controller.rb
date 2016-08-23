class OrderExceptionsController < ApplicationController

  #before_filter :require_internal

  def create
    exception = OrderException.create(params[:order_exception])
    render json: exception
  end

  def destroy
    exception = OrderException.find(params[:id])
    exception.destroy
    render json: exception
  end
end