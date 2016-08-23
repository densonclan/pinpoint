class ProofOfDeliveryImporter < Importer
  def model_class
    Pod
  end

  def self.field_names
    %w(tracking_number collection_date reference num_parcels_collected service_level postcode delivery_date delivery_depot num_parcels_delivered signature status)
  end

  def name
    'Pod'
  end

  def find_or_create_object(row)
    Pod.where(tracking_number: row['tracking_number']).first || Pod.new
  end  
end

