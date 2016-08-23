class CommentsController < ApplicationController

  before_filter :require_write_access, only: [:new, :create, :edit, :update, :destroy]

  def index
    @comments = Comment.accessible_by(current_user).for_listing.page params[:page]
  end

  def show
    @comment = Comment.accessible_by(current_user).find(params[:id])
  end

  def new
    @comment = Comment.new(commentable_id: params[:id], commentable_type: params[:type])
  end

  def create
    @comment = Comment.new_from_user(params[:comment], current_user)
    if @comment.save
      redirect_to redirect_path, notice: "Comment has been added."
    else
      flash[:error] = "Could not save the comment."
      render :new
    end
  end

  def edit
    @comment = Comment.accessible_by(current_user).find(params[:id])
  end

  def update
    @comment = Comment.accessible_by(current_user).find(params[:id])
    if @comment.update_attributes(params[:comment])
      redirect_to redirect_path, notice: "Changes have been saved."
    else
      flash[:error] = "Could not save changes."
      render :edit
    end
  end

  def destroy
    @comment = Comment.accessible_by(current_user).find(params[:id])
    @comment.destroy
    redirect_to redirect_path, notice: "Comment has been deleted."
  end

  private
  def redirect_path
    @comment.commentable_type == 'Order' ? notes_order_path(@comment.commentable_id) : notes_store_path(@comment.commentable_id)
  end
end