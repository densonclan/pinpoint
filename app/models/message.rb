class Message < ActiveRecord::Base
  has_paper_trail

  belongs_to :user
  belongs_to :receiver, :class_name => "User"

  scope :related, lambda { |user_id| where('user_id = ? OR receiver_id = ?',user_id, user_id) unless user_id.nil? }
  scope :archived, (lambda do where("archived = ?", true) unless nil? end)
  scope :unarchived, (lambda do where("archived = ?", false) unless nil? end)
  scope :unread, (lambda do where("read = ?", false) unless nil? end)
  scope :read, (lambda do where("read = ?", true) unless nil? end)
  scope :ordered, order('created_at DESC')
  scope :for_dashboard, unread.ordered.limit(5)

  #
  # Validations
  #
  validates_presence_of :subject
  validates_presence_of :full_text
  validates_presence_of :receiver_id
  validates_presence_of :user_id
  validates_length_of :subject, :maximum => 255

  attr_accessible :full_text, :subject, :archived, :read, :read_at, :user_id, :receiver_id

  after_create :deliver_message

  def read!
    update_attributes(read: true, read_at: Time.now) unless read?
  end

  def deliver_message
    MessageMailer.message_notification(self).deliver
  end    
end