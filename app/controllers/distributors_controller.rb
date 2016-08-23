class DistributorsController < ApplicationController
  
  before_filter :require_internal

  def index
    @distributors = Distributor.ordered
  end

  def new
    @distributor = Distributor.new
  end

  def create
    @distributor = Distributor.new(params[:distributor])
    if @distributor.save
      redirect_to distributors_path, notice: 'Distributor saved successfully'
    else
      flash[:error] = "Error saving distributor"
      render :new
    end
  end

  def edit
    @distributor = Distributor.find(params[:id])
  end

  def update
    @distributor = Distributor.find(params[:id])
    if @distributor.update_attributes(params[:distributor])
      redirect_to distributors_path, notice: 'Distributor saved successfully'
    else
      flash[:error] = "Error saving distributor"
      render :edit
    end
  end

  def destroy
    Distributor.find(params[:id]).destroy
    redirect_to distributors_path, notice: 'Distributor deleted successfully'
  end
end