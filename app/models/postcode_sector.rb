class PostcodeSector < ActiveRecord::Base

  validates_presence_of :area, :district, :sector, :residential, :business
  validates_length_of :area, maximum: 2
  validates_length_of :zone, maximum: 2
  before_validation :set_defaults
  
  scope :ordered, order(:area, :district, :sector) # for now
  scope :search, lambda {|q| where('concat(area,district,sector) LIKE ?', "#{q.upcase.gsub(/ /, '')}%")}

  attr_accessible :area, :district, :sector, :residential, :business, :zone

  def to_s
    "#{area}#{district} #{sector}"
  end
  
  def total
    residential + business
  end

  private

  def set_defaults
    self.residential = 0 unless residential
    self.business = 0 unless business
  end
end