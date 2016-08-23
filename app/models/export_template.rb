class ExportTemplate < ActiveRecord::Base
  attr_accessible :name, :value

  validates_presence_of :name
  validates_presence_of :value

  validates_length_of :name, :maximum => 140

  scope :ordered, order(:name)

end