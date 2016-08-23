class Task < ActiveRecord::Base
  has_paper_trail
  after_update :check_date, :send_status_change_email

  belongs_to :department
  belongs_to :user
  belongs_to :agent, :class_name => "User"
  belongs_to :store

  before_validation :set_default_priority
  before_validation :lookup_store, on: :create
  before_validation :ensure_department_or_user_set

  after_save :send_notification_email

  scope :related, lambda { |user_id| where('user_id = ? OR agent_id = ?',user_id, user_id) unless user_id.nil? }
  scope :archived, where("archived = ?", true)
  scope :unarchived, where("archived = ?", false)
  scope :for_department, lambda {|department_id| where(:department_id => department_id) }
  scope :for_user, lambda { |d| where("agent_id = ?", d) }
  scope :for_user_or_department, lambda { |user| where("agent_id=? OR (department_id=? AND for_department=?)", user.id, user.department_id, true) }
  scope :for_order, lambda { |o| where("order_id = ?", o) unless nil? }
  scope :ordered, order(:due_date)
  scope :for_dashboard, ordered.limit(5)
  scope :due_yesterday, where(due_date: Date.yesterday)
  scope :with_agents, includes(:agent)
  scope :assigned_to_a_user, where('agent_id IS NOT NULL')

  validates_datetime :due_date, :on_or_after => :today, :on => 'create'
  validates :completion, :presence => true, :numericality => { :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100 }
  validates :priority, :presence => true, :numericality => { :greater_than_or_equal_to => 0, :less_than_or_equal_to => 2 }
  validates :full_text, :presence => true
  validates :due_date, :presence => true

  attr_accessible :agent_id,:due_date, :completed, :completion, :full_text, :priority, :department_id, :user_id, :for_department, :archived, :account_number
  attr_accessor :account_number

  def self.new_with_user(params, user)
    task = Task.new(params)
    task.user = user
    task
  end    

  def self.accessible_by(user)
    user.internal? ? where('1=1') : where('(agent_id=? OR user_id=?) OR (department_id=? AND for_department=?)', user.id, user.id, user.department_id, true)
  end

  def self.notify_overdue_tasks
    Task.due_yesterday.unarchived.assigned_to_a_user.with_agents.each {|t| TaskMailer.overdue_task_notification(t).deliver }
  end

  def archive!
    self.archived = true
    self.save
  end

  def unarchive!
    self.archived = false
    self.save
  end

  #
  # If the date is past today, archive the task
  #
  def check_date
    #
    # Use .end_of_day to check if the day has officialy gone, providing that the task has default hour of 0:00:00
    #
    if self.due_date.end_of_day.past?
      self.archived = true
    end
  end

  def set_default_priority
    self.priority = 0 unless priority
  end

  def lookup_store
    if account_number && user
      self.store = Store.accessible_by(user).find_by_account_number(account_number)
      errors.add(:store, "account number invalid '#{account_number}'") unless store
    end
  end

  def ensure_department_or_user_set
    self.for_department = true unless department_id.blank?
    self.agent_id = nil if for_department
  end

  private
  def send_notification_email
    TaskMailer.assigned_task_notification(self).deliver if agent_id && agent_id != agent_id_was && agent
  end

  def send_status_change_email
    TaskMailer.priority_change_notification(self).deliver if agent_id && completion != completion_was && agent
  end
end