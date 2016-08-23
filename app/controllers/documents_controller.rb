class DocumentsController < ApplicationController

  before_filter :require_write_access, only: [:new, :create, :edit, :update, :destroy]
  before_filter :find_document, only: [:edit, :update, :destroy]

  def index
    @documents = Document.accessible_by(current_user).page(params[:page])
  end

  def search
    @documents = Document.accessible_by(current_user).search(params[:query]).page params[:page]
  end

  def new
    @document = Document.new store_id: params[:store_id]
  end

  def create
    @document = Document.new_with_user(params[:document], current_user)
    if @document.save
      redirect_to documents_store_path(@document.store_id), notice: 'Document saved successfully'
    else
      flash[:error] = "Error saving document"
      render :new
    end
  end

  def edit
  end

  def update
    if @document.update_attributes(params[:document])
      redirect_to documents_store_path(@document.store_id), notice: 'Document updated successfully'
    else
      flash[:error] = "Error saving document"
      render :edit
    end
  end

  def destroy
    @document.destroy
    redirect_to documents_store_path(@document.store_id), notice: 'Document deleted successfully'
  end

  private
  def find_document
    @document = Document.accessible_by(current_user).find(params[:id])
  end
end