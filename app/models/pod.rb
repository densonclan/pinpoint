class Pod < ActiveRecord::Base

  validates_presence_of :tracking_number, :postcode
  
  scope :ordered, order('collection_date DESC', 'delivery_date DESC', :postcode) # for now

  attr_accessible :tracking_number, :collection_date, :reference, :num_parcels_collected, :service_level, :postcode, :delivery_date, :delivery_date, :delivery_depot, :num_parcels_delivered, :status, :signature

  def to_s
    "#{postcode}"
  end
  
  def self.search(q)
    
    where('pods.tracking_number ILIKE ? OR pods.business_name ILIKE ? OR pods.postcode ILIKE ? OR pods.delivery_depot ILIKE ? OR pods.signature ILIKE ? ', "%#{q}%", "%#{q}%", "%#{q}%", "%#{q}%","%#{q}%")
  end

end
