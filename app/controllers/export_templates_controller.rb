class ExportTemplatesController < ApplicationController

  def index
    @templates = ExportTemplate.all
  end

  def new
    @template = ExportTemplate.new
  end

  def create
    @template = ExportTemplate.new(params[:export_template])
    if @template.save
      redirect_to export_templates_path, notice: "Export template has been added"
    else
      flash[:error] = "Template could not be saved."
      render :new
    end
  end

  def edit
    @template = ExportTemplate.find(params[:id])
  end

  def update
    @template = ExportTemplate.find(params[:id])
    if @template.update_attributes(params[:export_template])
      redirect_to export_templates_path, notice: 'Template has been updated'
    else
      flash[:error] = "Could not save the template"
      render :edit
    end
  end

  def destroy
    ExportTemplate.find(params[:id]).destroy
    redirect_to export_templates_path, notice: 'Template deleted successfully'
  end
end