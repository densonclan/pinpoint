class DistributionsController < ApplicationController

  def show
    redirect_to order_path(Distribution.ordered.find(params[:id]).order_id)
  end
end