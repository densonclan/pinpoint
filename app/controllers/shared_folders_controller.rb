class SharedFoldersController < ApplicationController
  def index
    if(current_user.folders.where(id: params[:folder_id]).any?)
      folders = SharedFolder.where(folder_id: params[:folder_id])
      return render json: folders.as_json(:include => :user)
    end

    head :not_found
  end

  def create
    if(current_user.folders.where(id: params[:folder_id]).any?)
      if params[:users]
        shared_folders = SharedFolder.where('folder_id = ?', params[:folder_id].to_i)
        user_ids = shared_folders.map {|f| f.user.id.to_s }

        to_be_deleted = (user_ids - params[:users]).map(&:to_i)
        SharedFolder.where('folder_id = ? and user_id in (?)', params[:folder_id].to_i, to_be_deleted).destroy_all

        to_be_added = params[:users] - user_ids
        to_be_added.each do |user|
          shared_folder = SharedFolder.create(folder_id: params[:folder_id].to_i, user_id: user)
          SharedFolderMailer.notify(shared_folder).deliver
        end
      else
        SharedFolder.where('folder_id = ?', params[:folder_id].to_i).destroy_all
      end

      return head :ok
    end
    head :not_found
  end
end