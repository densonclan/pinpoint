class ReportsController < ApplicationController

  before_filter :require_internal, only: [:clients]

  def index
  end

  def activity
    @resources = (params[:type] == 'stores' ? Store : Order).\
      accessible_by(current_user).\
      updated_by(params[:updated_by]).\
      updated_after(params[:date_from]).\
      updated_before(params[:date_to]).\
      matching_account_number(params[:account_number]).\
      for_activity_list.\
      reverse_update_order.\
      page(params[:page])
  end

  def stores
    @stores = Store.with_clients.accessible_by(current_user).search(params[:query]) if !params[:account_number].blank?
  end

  def store
    store = Store.accessible_by(current_user).find_by_account_number(params[:account_number].upcase) unless params[:account_number].blank?
    if store.nil?
      flash[:error] = 'Please enter a valid store number'
      return redirect_to stores_reports_path
    end
    @reporter = StoreOrderReporter.new(store, current_user, params)
  end

  def clients
    @clients = Client.with_periods
  end

  def business_managers
    @business_managers = BusinessManager.accessible_by(current_user)
  end

  def business_manager
    @business_manager = BusinessManager.accessible_by(current_user).find(params[:manager])
  end

  def quantities
    @reporter = OrderQuantityReporter.new(current_user, params)
    respond_to do |r|
      r.xls { write_export_quantity_report }
      r.html
    end
  end

  private

  def write_export_quantity_report
    exporter = OrderQuantityReportExporter.new(@reporter)
    send_data(exporter.export, filename: exporter.file_name, type: "application/vnd.ms-excel", disposition: 'attachment')
  end
end
