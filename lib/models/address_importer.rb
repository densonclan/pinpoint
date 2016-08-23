class AddressImporter < Importer

  def model_class
    Address
  end

  def self.field_names
    %w(title full_name first_line second_line third_line city postcode county phone_number email address_type business_name)
  end
end