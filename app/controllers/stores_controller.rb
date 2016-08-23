class StoresController < ApplicationController
  helper_method :sort_column, :sort_direction

  before_filter :require_write_access, only: [:new, :create, :edit, :update, :destroy]
  before_filter :lookup_store, only: [:show, :other, :documents, :orders, :notes, :edit, :update, :map, :destroy]

  def index
    @stores = apply_filter.list_for(current_user).order_by(params[:sort], params[:direction]).page(params[:page])
  end

  def advanced
    @stores = apply_filter.list_for(current_user).order_by(params[:sort], params[:direction]).filter(params[:client], params[:business_manager], params[:county]).page params[:page]
    render :index
  end

  def export
    exporter = StoreExporter.new(current_user, params)
    send_data(exporter.export, filename: 'stores.xls', type: "application/vnd.ms-excel", disposition: 'attachment')
  end

  def show
    respond_to do |r|
      r.html
      r.pdf { prawnto prawn: {margin: 20, page_size: "A4"} }
    end
  end

  def documents
    @documents = @store.documents.ordered.page params[:page]
  end

  def orders
    sort = params[:sort] || 'periods.date_dispatch'
    direction = params[:direction] || 'desc'
    @orders = @store.orders.for_listing.order("#{sort} #{direction}").page params[:page]
  end

  def notes
    @comments = @store.comments.ordered.page params[:page]
  end

  #
  # Lookup a store by an account number
  #
  def lookup
    if !params[:account_number].blank?
      store = Store.find_by_account_number(params[:account_number])
      if store.blank?
        redirect_to search_stores_path(:query => params[:account_number])
      else
        redirect_to store_path(:id => store.id)
      end
    else
      flash[:error] = "You have not entered Store's account number."
      redirect_to root_path
    end
  end

  def other
    @stores = @store.find_others.for_listing.order_by(params[:sort], params[:direction]).page(params[:page])
  end

  def map
  end

  def new
    @store = Store.new
  end

  def create
    @store = Store.new_with_user(params[:store], current_user)
    if @store.save
      @store.lock! current_user
      redirect_to new_address_path(store_id: @store.id), notice: "Store has been added."
    else
      flash[:error] = "Could not save the store."
      render :new
    end
  end

  def edit
  end

  def update
    @store.set_attributes_with_user params[:store], current_user
    if @store.save
      redirect_to @store, notice: "Changes have been saved"
    else
      flash[:error] = "Could not save changes"
      render :edit
    end
  end

  def destroy
    @store.updated_by = current_user
    if @store.destroy
      redirect_to stores_path, notice: "Store has been deleted."
    else
      render :edit
    end
  end

  def search
    @stores = apply_filter.accessible_by(current_user).for_listing.search(params[:query]).order_by(params[:sort], params[:direction]).page params[:page]
  end

  def suggest
    render json: Store.accessible_by(current_user).matching(params[:term]).limit(5).map {|s| s.account_number}
  end

  private

  def lookup_store
    @store = Store.accessible_by(current_user).find(params[:id])
  end    

    def sort_column
      params[:sort] ||= 'account_number'
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

 private
  def apply_filter
    case params[:type]
      when 'participating' then return Store.participating
      when 'nologo' then return Store.nologo
      when 'noorders' then return Store.noorders
      else return Store.where('1=1')
    end

  end


end