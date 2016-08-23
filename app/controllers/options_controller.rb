class OptionsController < ApplicationController

  before_filter :require_internal

  def index
    @options = Option.for_listing.ordered
  end

  def new
    @option = Option.new
  end

  def create
    @option = Option.new(params[:option])
    if @option.save
      redirect_to options_path, notice: 'Option saved successfully'
    else
      flash[:error] = "Error saving option"
      render :new
    end
  end

  def edit
    @option = Option.with_all_values.find(params[:id])
  end

  def update
    @option = Option.with_all_values.find(params[:id])

    if @option.update_attributes(params[:option])
      redirect_to options_path, notice: 'Option saved successfully'
    else
      flash[:error] = "Error saving option"
      render :edit
    end
  end

  def destroy
    Option.find(params[:id]).destroy
    redirect_to options_path, notice: 'Option deleted successfully'
  end
end