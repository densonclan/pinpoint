class TransportsController < ApplicationController

  before_filter :require_allow_import

  def create
    @transport = Transport.new_with_user(params[:transport], current_user)
    if @transport.save
      redirect_to importer_index_path, notice: "Import created successfully. Execution will begin within the next 10 minutes and the results will be emailed to #{current_user.email}"
    else
      flash[:error] = "You have not selected a file or chosen the correct section."
      render 'importer/index'
    end
  end
end