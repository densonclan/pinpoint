module ExporterHelper

  def export_period_options
    options_from_collection_for_select exporter_period_options, :id, :name

  end

  def order_status_options
    options_for_select([ ['Awaiting print', 0], ['Printed',1], ['Distributed', 2]  ])
  end

  def template_options
    options_from_collection_for_select ExportTemplate.all.sort! { |a,b| a.name.downcase <=> b.name.downcase }, :id, :name
  end

  def exporter_menu_class(controller)
    params[:controller] == controller ? 'active' : nil
  end

  def export_template_fields
    ([Order, Option, Page, Client, Store, Distribution].map {|c| field_names_for(c)} + extra_store_template_fields + extra_order_template_fields + extra_distribution_template_fields + address_template_fields + publisher_address_template_fields).flatten.sort.join(',')
  end

  def field_names_for(c)
    export_template_fields_for(c).map {|f| export_template_field_name(c.name, f)}
  end

  def extra_order_template_fields
    ['Order-Total NEP Boxes', 'Order-Total GH Boxes', 'Order-Total Store Boxes', 'Order-Total Boxes']
  end

  def extra_store_template_fields
    ['Store-Description']
  end

  def address_template_fields
    export_template_fields_for(Address).map {|f| export_template_field_name('Store Address', f)}
  end

  def publisher_address_template_fields
    export_template_fields_for(Address).map {|f| export_template_field_name('Publisher Address', f)}
  end

  def address_template_fields_for_address(type)
    export_template_fields_for(Address).map {|f| export_template_field_name(type, "Address #{f}")}
  end

  def export_template_fields_for(c)
    eval("#{c.column_names}").reject{|f| f =~ /created_at|updated_at|id|description|address_type/ }
  end

  def extra_distribution_template_fields
    ['Distribution-Type', 'Distribution-Date Of Distribution', 'Distribution-Delivery Postcode', 'Distribution-Leaflet Number', 'Distribution-Total Boxes'] +
    address_template_fields_for_address('Distribution')
  end

  def export_template_field_name(c, f)
    "#{c}-#{f.titleize}"
  end

  def ship_via_export_options
    ship_via_options
  end

  def running_order_options
    options = []
    options << 'Store Urgents'
    ['Royal Mail', 'Newspaper', 'Solus Team', 'In Store', 'Store Own Dist'].each do |s|
      (-2..2).each do |i|
        case i
          when -2 then options << "#{s} 2 weeks prior"
          when -1 then options << "#{s} week prior"
          when 0 then options << "#{s} week of promo"
          when 1 then options << "#{s} week after"
          when 2 then options << "#{s} 2 weeks after"
        end
      end
    end
    options << 'Blanks'

  end
end