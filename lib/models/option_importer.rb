class OptionImporter < Importer

  def model_class
    Option
  end

  def self.field_names
    %w(name description box_quantity price_zone multibuy licenced total_ambient total_licenced total_temp total_quantity reference_number client page)
  end

  def set_extra_attributes(option, row, i)
    set_client(option, row['client'], i)
    set_page(option, row['page'], i)
  end

  def set_page(option, page_name, i)
    return if page_name.blank? || option.client.blank?
    page = Page.where('name=? OR reference_number=?', page_name, page_name).first
    if page
      option.current_value.page = page
    else
      save_error i, "Unrecognised page name '#{page_name}'. Valid values are: #{page_options}"
    end
  end

  def page_options
    @page_options ||= Page.names.join(', ')
  end

end