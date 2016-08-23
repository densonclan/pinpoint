class MessageMailer < ActionMailer::Base
  default from: "pinpoint@gaskandhawley.com"

  def import_complete(importer)
    @errors = importer.errors
    @success_count = importer.success_count
    @name = importer.name.downcase
    mail to: importer.user.email, subject: "PinPoint #{@name} import complete"
  end

  #
  # Send a notification of a new message
  #
  def message_notification(message)
  	@message = message
  	@root_url = "http://www.pinpointlms.co.uk/auth/login"
  	@message_url = "http://www.pinpointlms.co.uk/messages/#{@message.id}"
  	mail(:to => recipient(@message.receiver.email), :subject => "[PinPoint] New message notification from #{@message.user.name}") do |format|
      format.html
    end
  end

  #
  # Send a notification of a task assignment
  #
  def task_notification(task)
    @task = task
    @root_url = "http://www.pinpointlms.co.uk/auth/login"
    @task_url = "http://www.pinpointlms.co.uk/tasks/#{@task.id}"

    #
    # If the task is not assigned to the department, send to the agent
    #
    if task.for_department == false
      mail(:to => recipient(@task.agent.email), :subject => "[PinPoint] New task notification from #{@task.user.name}") do |format|
        format.html
      end

    #
    # Otherwise, send to each user in the department
    #
    else
      task.department.users.each do |u|
        mail(:to => recipient(u.email), :subject => "[PinPoint] New task notification from #{@task.user.name}") do |format|
          format.html
        end
      end
    end

  end

  #
  # Send a notification of a due task
  #
  def due_task_notification(task)
    @task = task
    @root_url = "http://www.pinpointlms.co.uk/auth/login"
    @task_url = "http://www.pinpointlms.co.uk/tasks/#{@task.id}"

    #
    # If the task is not assigned to the department, send to the agent
    #
    if task.for_department == false
      mail(:to => recipient(@task.agent.email), :subject => "[PinPoint] Due task notification from #{@task.user.name}") do |format|
        format.html
      end

    #
    # Otherwise, send to each user in the department
    #
    else
      task.department.users.each do |u|
        mail(:to => recipient(u.email), :subject => "[PinPoint] Due task notification from #{@task.user.name}", :content_type => 'text/html') do |format|
          format.html
          format.text
        end
      end
    end

  end

  def recipient(r)
    Rails.env.development? ? 'barry.denson@gaskandhawley.com' : r
  end
end