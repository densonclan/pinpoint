class UsersController < ApplicationController

  before_filter :require_admin

  def index
    @users = User.with_client.ordered
  end

  def activate
    if User.find(params[:id]).activate!
      redirect_to users_path, notice:  'User activated successfully'
    else
      flash[:error] = 'Unable to activate user - check they belong to a client'
      redirect_to users_path
    end
  end

  def deactivate
    User.find(params[:id]).deactivate!
    redirect_to users_path, notice: "User deactivated successfully"
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes params[:user]
      redirect_to users_path, notice: "User saved successfully"
    else
      flash[:error] = 'Error saving user'
      render :edit
    end
  end

  def destroy
    User.find(params[:id]).destroy
    redirect_to users_path, notice: "User has been deleted."
  end
end