class TaskMailer < ActionMailer::Base
  default from: "pinpoint@gaskandhawley.com"
  helper :tasks

  def assigned_task_notification(task)
    @task = task
    mail to: recipient(task.agent.email), subject: 'You have been assigned a Pinpoint task'
  end

  def overdue_task_notification(task)
    @task = task
    mail to: recipient(task.agent.email), subject: 'You have an overdue Pinpoint task'
  end

  def priority_change_notification(task)
    @task = task
    mail to: recipient(task.agent.email), subject: 'A Pinpoint task you have been assigned has changed'
  end

  def recipient(r)
    Rails.env.development? ? 'barry.denson@gaskandhawley.com' : r
  end
end