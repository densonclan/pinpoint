class FoldersController < ApplicationController
  def index
    @folders = current_user.folders.roots
    @shared_folders = current_user.shared_folders
    @files = []
  end

  def create
    if (!params[:folder][:parent_id].blank? && current_user.folders.where(id: params[:folder][:parent_id]).empty?)
      flash[:error] = "Cant create folder in shared folder"
      return redirect_to action: :browse, id: params[:folder][:parent_id]
    end

    @folder = current_user.folders.create(params[:folder])

    if params[:folder][:parent_id]
      redirect_to action: :browse, id: @folder.id
    else
      redirect_to action: :index
    end
  end

  def destroy
    current_user.folders.find(params[:id]).destroy
    redirect_to(request.referer || folders_path)
  end

  def browse
    folder = Folder.find(params[:id])
    @folder = folder if current_user.has_share_access?(folder)
    if @folder
      @folders = @folder.children
      @files = @folder.files
      @shared_folders = []
      render action: :index
    else
      flash[:error] = "Don't be cheeky! Mind your own folders!"
      redirect_to root_url
    end
  end
end