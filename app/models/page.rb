class Page < ActiveRecord::Base
  has_paper_trail
  has_many :orders

  validates_uniqueness_of :reference_number, :case_sensitive => false
  validates_uniqueness_of :name, :case_sensitive => false
  validates_length_of :reference_number, :maximum => 32
  validates_length_of :description, :maximum => 255
  validates_presence_of :name

  attr_accessible :description, :name, :reference_number, :box_quantity

  scope :ordered, order(:reference_number)

  def self.names
    select(:name).order(:name).map{|p| p.name}.uniq
  end
end