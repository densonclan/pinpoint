class BargainBoozeController < ApplicationController

  before_filter :require_admin

  def index
    @transport = Transport.new
  end

  def create
    if params[:spreadsheet].present?
      exporter = BargainBoozeExporter.new(params[:spreadsheet])
      send_data( exporter.export, filename: 'export.xls', type: "application/vnd.ms-excel", disposition: 'attachment')
    else
      flash.now[:error] = 'You have not selected a file'
      render :index
    end
  end

  #def history
  #  @transports = Transport.bargain_booze.ordered.page params[:page]
  #end

end
