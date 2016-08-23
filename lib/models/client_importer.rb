class ClientImporter < Importer

  def model_class
    Client
  end

  def self.field_names
    %w(name description code reference)
  end
end