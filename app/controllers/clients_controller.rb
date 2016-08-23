class ClientsController < ApplicationController

  before_filter :require_internal

  def index
    @clients = Client.ordered.page(params[:page])
  end

  def new
    @client = Client.new
  end

  def create
    @client = Client.new(params[:client])
    if @client.save
      redirect_to clients_path, notice: 'Client saved successfully'
    else
      flash[:error] = "Error saving client"
      render :new
    end
  end

  def edit
    @client = Client.find(params[:id])
  end

  def update
    @client = Client.find(params[:id])
    if @client.update_attributes(params[:client])
      redirect_to clients_path, notice: 'Client saved successfully'
    else
      flash[:error] = "Error saving client"
      render action: 'edit'
    end
  end

  def destroy
    Client.find(params[:id]).destroy
    redirect_to clients_path, notice: 'Client deleted successfully'
  end
end