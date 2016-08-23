class Distributor < ActiveRecord::Base
  has_many :distributions

  #
  # Validations
  #
  validates_presence_of :name
  validates_presence_of :distributor_type
  validates_length_of :description, :maximum => 5000, :allow_blank => true
  validates_length_of :reference_number, :maximum => 32, :allow_blank => true

  attr_accessible :description, :name, :reference_number, :distributor_type

  scope :ordered, order(:name)

  IN_STORE = 'in-store'
  IN_STORE_OWN = 'store-own-dist'

  def in_store?
    distributor_type == IN_STORE || distributor_type == IN_STORE_OWN
  end
end