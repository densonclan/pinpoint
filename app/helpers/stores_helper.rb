module StoresHelper

  def store_menu_class(action)
    params[:action] == action ? 'active' : nil
  end

  def logo_url(store)
    pdf_path = "/logos/#{store.account_number}.PDF"
    return pdf_path if File.exists?("#{Rails.root.to_s}/public" + pdf_path)
    "/logos/#{store.logo}.BMP"
  end

  def logo_path(store)
    "#{Rails.root.to_s}/public#{logo_url(store)}"
  end

  def store_has_logo?(store)
    store.logo && File.exists?(logo_path(store))
  end

  def logo_image_tag(store)
    store_has_logo?(store) ? logo_tag(store) : nil
  end

  def logo_tag(store)
    return image_tag(logo_url(store)) if File.extname(logo_path(store)) == '.BMP'
    tag('embed', src: logo_url(store) + '#toolbar=0', style: "width: 80mm; height: 297mm")
  end

  def logo_updated_at(store)
    File.new(logo_path(store)).mtime.strftime('%d %b %y at %k:%M')
  end

  def preferred_distribution_options
    ['Newspaper', 'Royal Mail', 'Solus', 'Store Delivery']
  end

  def options_for_store(store)
    store.client ? Option.for_client(store.client).ordered : options
  end

  def stores_page_title
    case params[:type]
      when 'nologo' then return "Stores without a logo"
      when 'noorders' then return "Stores with no orders"
      when 'participating' then return "Participation Only Stores"
      else return 'Stores'
    end
  end  

  def store_tab_class(tab)
    (params[:action] == 'index' && tab == 'index' &&  params[:type] == nil) || tab == params[:type] ? 'active' : nil
  end

end