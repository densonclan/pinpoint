class UploadedFilesController < ApplicationController
  def create
    folder = Folder.find(params[:folder_id])
    @folder = folder if current_user.has_share_access?(folder)
    if @folder
      @file = folder.files.create(file: params[:file])
      return head :ok  
    end
    
    head :not_found
  end

  def destroy
    folder = Folder.find(params[:folder_id])
    @folder = folder if current_user.has_share_access?(folder)
    if @folder and @folder.files.find(params[:id])
      file = UploadedFile.find(params[:id])
      file.destroy
      return redirect_to(request.referer || folders_path)
    end

    head :not_found
  end

  def show
    file = UploadedFile.find(params[:id])
    if file
      return send_file file.file.path, :type => file.file_content_type
    end

    head :not_found
  end
end