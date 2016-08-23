class Department < ActiveRecord::Base
  #
  # TODO: Go through all users and remove those who are not in 'the chosen' array
  #
  before_destroy :reassign_users
  before_validation :create_shortcode

  has_many :users
  has_many :tasks

  validates_presence_of :name
  validates_presence_of :short_code
  validates_length_of :description, :maximum => 400, :allow_blank => true

  attr_accessible :description, :name, :short_code

  scope :ordered, order(:name)
  scope :accessible_by, lambda {|user| where(user.internal? ? true : {id: user.department_id}) }

  private

    #
    # If the department gets deleted, unassign users
    #
    def reassign_users
      self.users.each do |u|
        u.department = nil
        u.save
      end
    end

    #
    # Before validating, update short_code field
    #
    def create_shortcode
      if self.name.blank?
        self.short_code = nil
      else
        self.short_code = self.name.downcase.gsub(/\s/,'-')
      end
    end
end
