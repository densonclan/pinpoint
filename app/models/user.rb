class User < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :timeoutable

  ADMIN = 1
  DISTRIBUTION = 2
  CLIENT = 3
  READ_ONLY = 4
  COURIER = 5

  scope :recently_signed_in, where('last_request_at > ?', 5.minutes.ago)
  scope :recently_viewed, lambda { |request| { :conditions => ['last_request_at > ? AND last_request = ?', 5.minutes.ago, request ] } }
  scope :with_client, includes(:client)
  scope :all_admins, where(user_type: ADMIN)
  

  #
  #  Associations
  #
  belongs_to :department
  belongs_to :client
  has_many :documents
  has_many :tasks, :dependent => :destroy
  has_many :assigned_tasks, :foreign_key => "agent_id", :class_name => "Task"
  has_many :messages, :dependent => :destroy
  has_many :received_messages, :foreign_key => "receiver_id", :class_name => "Message"
  has_many :comments, :dependent => :destroy
  has_many :orders
  has_many :stores
  has_many :transports
  has_many :updates, :foreign_key => 'updated_by_id'

  has_many :folders
  has_many :shared_folders

  after_create :deliver_require_activation_email

  validates_presence_of :email
  validates_presence_of :name
  validates_presence_of :department
  validates_presence_of :phone
  validates_presence_of :client_id, if: Proc.new {|user| !user.internal? && user.approved}

  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "48x48>" }, :default_url => "default_:style_avatar.png"

  attr_accessible :name, :email, :encrypted_password, :password, :password_confirmation, :remember_me, :department_id, :department, :phone, :approved, :avatar, :last_request, :last_request_at, :user_type, :client_id

  scope :ordered, order(:name)

  def self.accessible_by(user)
    user.internal? ? scoped : where('client_id=? OR user_type=? OR user_type=?', user.client_id, ADMIN, DISTRIBUTION)
  end

  def internal?
    admin? || distribution?
  end

  def importer?
    admin? || distribution? || courier?
  end

  def admin?
    user_type == ADMIN
  end

  def distribution?
    user_type == DISTRIBUTION
  end

  def write_access?
    internal? || user_type == CLIENT
  end

  def read_only?
    user_type == READ_ONLY
  end

  def courier?
    user_type == COURIER
  end


  #
  # List all messages related to the model
  #
  def related_messages
    Message.related(self.id)
  end

  #
  # List all tasks related to the model
  #
  def related_tasks
    Task.where('(agent_id = ? OR user_id = ?) OR (department_id = ? AND for_department = ?)',self.id, self.id, self.department_id, true)
  end

  #
  # List all tasks assigned to the user including those from department
  #
  def assigned_tasks_include_departments
    Task.where('(agent_id = ?) OR (department_id = ? AND for_department = ?)',self.id, self.department.id, true)
  end

  #
  # Tasks to do
  #
  def departmental_assigned_tasks
    assigned_tasks.for_department(department_id)
  end

  def activate!
    self.approved = true
    save
    deliver_user_activated_email
  end

  def deactivate!
    self.approved = false
    save
  end

  #
  # Check if approved
  #
  def active_for_authentication?
    super && approved?
  end

  #
  # If the user is not active, display error message ( taken from Devise locale's file )
  #
  def inactive_message
    if !approved?
      :not_approved
    else
      super # Use whatever other message
    end
  end

  def shared_folders_by_others
    SharedFolder.where(user_id: id).map(&:folder)
  end

  def has_share_access?(folder) 
    #has share access if the folder is one of one of his own 
    return true if self.folders.include?(folder) 
  
    #has share access if the folder is one of the shared_folders_by_others 
    return true if self.shared_folders_by_others.include?(folder) 
  
    #for checking sub folders under one of the being_shared_folders 
    return_value = false
  
    folder.ancestors.each do |ancestor_folder| 
    
      return_value = self.shared_folders_by_others.include?(ancestor_folder) 
      if return_value #if it's true 
        return true
      end
    end
  
    return false
  end

  private
  def deliver_require_activation_email
    UserMailer.require_activation_email(self).deliver unless approved
  end

  def deliver_user_activated_email
    UserMailer.user_activated_email(self).deliver
  end
end
