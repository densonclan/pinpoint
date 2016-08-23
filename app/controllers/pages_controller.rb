class PagesController < ApplicationController

  before_filter :require_internal

  def index
    @pages = Page.ordered
  end

  def new
    @page = Page.new
  end

  def create
    @page = Page.new(params[:page])
    if @page.save
      redirect_to pages_path, notice: 'Page saved successfully'
    else
      flash[:error] = "Error saving page"
      render :new
    end
  end

  def edit
    @page = Page.find(params[:id])
  end

  def update
    @page = Page.find(params[:id])

    if @page.update_attributes(params[:page])
      redirect_to pages_path, notice: 'Page saved successfully'
    else
      flash[:error] = 'Error saving page'
      render :edit
    end
  end

  def destroy
    Page.find(params[:id]).destroy
    redirect_to pages_path, notice: 'Page deleted successfully'
  end
end