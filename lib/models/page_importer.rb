class PageImporter < Importer

  def model_class
    Page
  end

  def self.field_names
    %w(name description reference_number)
  end
end