class PostcodeSectorImporter < Importer
  def model_class
    PostcodeSector
  end

  def self.field_names
    %w(area district sector residential business zone)
  end

  def name
    'BigTrev'
  end

  def find_or_create_object(row)
    PostcodeSector.where(area: row['area'], district: row['district'], sector: row['sector']).first || PostcodeSector.new
  end  
end