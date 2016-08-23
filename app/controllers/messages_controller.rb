class MessagesController < ApplicationController

  #
  # List all unarchived received messages, ordered by the date they have been created at.
  #
  def index
    @messages = current_user.received_messages.order('created_at DESC').unarchived.paginate(:page => params[:page], :per_page => 10)
  end

  #
  # List all unarchived messages that a logged in user has sent out
  #
  def sent
    @messages = current_user.messages.order('created_at DESC').unarchived.paginate(:page => params[:page], :per_page => 10)
  end

  #
  # List all received and archived messages
  #
  def archived
    @messages = current_user.received_messages.order('created_at DESC').archived.paginate(:page => params[:page], :per_page => 10)
  end

  #
  # Archive given message
  #
  def archive
    @message = current_user.received_messages.find(params[:id])

    if @message.update_attribute('archived', true)
      flash[:notice] = "Message archived."
    else
      flash[:error] = "Message could not archived."
    end
    redirect_to messages_path
  end

  #
  # Unarchive given message
  #
  def unarchive
    @message = current_user.received_messages.find(params[:id])

    if @message.update_attribute('archived', false)
      flash[:notice] = "Message unarchived."
    else
      flash[:error] = "Message could not unarchived."
    end
    redirect_to messages_path
  end



  def new
  	@message = Message.new receiver_id: params[:user_id]
  end

  def show
    @message = Message.related(current_user.id).find(params[:id])
    @message.read! if current_user == @message.receiver
  end

  def create
  	@message = current_user.messages.build(params[:message])
    if @message.save
      redirect_to sent_messages_path, notice: 'Message has been sent.'
    else
      render 'new'
    end
  end

  #
  # Save given message as a task
  #
  def save_task
    @message = Message.related(current_user.id).find(params[:message_id])

    @task = Task.new
    @task.full_text = @message.full_text
    @task.user_id = current_user.id
    @task.agent_id = current_user.id

    render '/tasks/new'
  end

  #
  # Delete given message, make sure the message belongs to a logged in user
  #
  def destroy
  	if @message = Message.related(current_user.id).find(params[:id])

      if @message.destroy
        flash[:notice] = "Message deleted."
      else
        flash[:error] = "Message could not deleted."
      end

    else
      flash[:error] = "Message could not be deleted. You are not the owner of the message."
    end
    redirect_to messages_path
  end
end
