class ImporterController < ApplicationController

  before_filter :require_allow_import

  def index
    @transport = Transport.new
  end

  def template
    name = params[:id].camelize
    send_data initialize_importer(name).field_names_as_csv, filename: "Pinpoint_#{name}_Template.csv", type: 'text/csv', disposition: 'attachment'
  end

  def history
    @transports = Transport.ordered.page params[:page]
  end

  def cancel
    flash[:success] = 'Import cancelled successfully' if Transport.find(params[:id]).cancel!
    redirect_to history_importer_index_path
  end

  #
  # Get given file
  #
  def file
    if params[:id]
      if transport = Transport.find(params[:id])
        send_file(transport.file_path)
      else
        flash[:error] = "Could not find given file"
        redirect_to :action => 'index'
      end
    else
      flash[:error] = "Missing URL parameter"
      redirect_to :action => 'index'
    end
  end

  private
  def initialize_importer(name)
    Object.const_get("#{name}Importer")
  end
end
