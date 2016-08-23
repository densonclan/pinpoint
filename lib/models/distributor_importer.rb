class DistributorImporter < Importer
  def model_class
    Distributor
  end

  def self.field_names
    %w(name distributor_type description reference_number)
  end
end