class RecordLocksController < ApplicationController

  def create
    params[:record_lock][:user] = current_user
    lock = RecordLock.new(params[:record_lock])
    render json: lock, status: lock.save ? 200 : 500
  end

  def destroy
    lock = RecordLock.find(params[:id])
    if lock.user == current_user
      lock.destroy
      render json: lock
    else
      render json: lock, status: 500
    end
  end
end