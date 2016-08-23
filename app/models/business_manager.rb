class BusinessManager < ActiveRecord::Base
  has_paper_trail

  belongs_to :client
  has_many :stores
  has_many :orders, :through => :stores

  extend AccessibleBy

  scope :by_name, lambda{ |name| where(:name => name) unless name.blank? }
  scope :ordered, order(:name)
  scope :for_listing, includes(:client, :stores)
  scope :search, lambda {|q| where('name ILIKE ? OR email ILIKE ? OR additional_info ILIKE ?', "%#{q}%", "%#{q}%", "%#{q}%")}
  scope :for_client, lambda {|client_id| where(client_id: client_id)}

  validates_uniqueness_of :name, :case_sensitive => false, scope: :client_id
  validates_presence_of :name
  validates :email, :uniqueness => true, :email => true, :allow_blank => true

  attr_accessible :additional_info, :email, :name, :phone_number, :reference_number, :business_manager_id, :client_id

  def self.find_by_name_case_insensitive(name)
    where('name ILIKE ?', name).first
  end
end