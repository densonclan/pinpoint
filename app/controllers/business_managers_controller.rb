class BusinessManagersController < ApplicationController

  before_filter :require_internal

  def index
    @managers = BusinessManager.for_listing.ordered.page(params[:page])
  end

  def search
    @managers = BusinessManager.for_listing.ordered.search(params[:query]).page(params[:page])
    render :index
  end

  def new
    @manager = BusinessManager.new
  end

  def create
    @manager = BusinessManager.new(params[:business_manager])
    if @manager.save
      redirect_to business_managers_path, notice: "New manager has been added."
    else
      flash[:error] = "Could not add new Manager."
      render :new
    end
  end

  def edit
    @manager = BusinessManager.find(params[:id])
  end

  def update
    @manager = BusinessManager.find(params[:id])
    if @manager.update_attributes(params[:business_manager])
      redirect_to business_managers_path, notice: 'Business Manager saved successfully'
    else
      flash[:error] = "Error saving this business manager"
      render :edit
    end
  end

  def destroy
    BusinessManager.find(params[:id]).destroy
    redirect_to business_managers_path, notice: 'Business Manager deleted successfully'
  end
end