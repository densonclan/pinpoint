class BusinessManagerImporter < Importer

  def model_class
    BusinessManager
  end

  def self.field_names
    %w(name email additional_info phone_number)
  end

  def set_extra_attributes(bm, row, i)
    set_client(bm, row['client'], i)
  end
end