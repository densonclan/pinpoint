class PodsController < ApplicationController

  def index
    @pods = Pod.ordered.page(params[:page])
  end

  def search

    @pods = Pod.search(params[:query]).page(params[:page])
    render :index
  end

  def new
    @pod = Pod.new
  end

  def create
    @pod = Pod.new(params[:pod])
    if @pod.save
      redirect_to pods_path, notice: 'POD saved successfully'
    else
      flash[:error] = "Error saving POD"
      render :new
    end
  end

end
