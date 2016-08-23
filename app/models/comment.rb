class Comment < ActiveRecord::Base
  has_paper_trail

  belongs_to :user
  belongs_to :commentable, :polymorphic => true

  validates :user, :presence => true
  validates_inclusion_of :commentable_type, :in => %w(Store Order)
  before_validation :titleize_commentable
  validate :check_commentable

  attr_accessible :commetable, :commentable_id, :commentable_type, :commentable, :full_text, :user_id, :save_as_task, :due_date, :assignee_id, :department_id

  after_save :create_task
  attr_accessor :save_as_task, :due_date, :assignee_id, :department_id

  scope :ordered, order('comments.updated_at DESC')
  scope :for_listing, includes(:user).ordered
  scope :accessible_by, lambda {|user| user.internal? ? where('1=1') : joins(:user).where('users.client_id=?', user.client_id) }

  def self.new_from_user(params, user)
    comment = Comment.new(params)
    comment.user_id = user.id
    comment
  end

  def create_task
    if save_as_task
      task = Task.new full_text: full_text, department_id: department_id, due_date: due_date, agent_id: assignee_id, user_id: user_id
      task.store = store_from_commentable
      task.save
    end
    true
  end

  def titleize_commentable
    self.commentable_type = commentable_type.titleize if commentable_type
  end

  def check_commentable
    if commentable_type && commentable_id && errors.empty? && !commentable
      errors.add(:commentable_id, 'Missing or invalid commentable item')
      return false
    end
    true
  end

  private

  def store_from_commentable
    if commentable
      return commentable if commentable_type == 'Store'
      return commentable.store if commentable_type == 'Order'
    end
  end
end