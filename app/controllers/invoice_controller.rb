class InvoiceController < ApplicationController

  def index
  end

  def processor
    exporter = InvoiceExporter.new(current_user, exporter_options)
    send_data(exporter.export, filename: exporter.file_name, type: "application/vnd.ms-excel", disposition: 'attachment')
  end

  private
  def exporter_options
    params.reject{|k,v| k == 'controller' || k == 'action'}
  end
end