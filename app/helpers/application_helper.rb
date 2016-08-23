module ApplicationHelper

  def nl2br(val)
    h(val).gsub(/\n/, "\n<br/>")
  end  

  def show_advanced_button_on_search_form?
    controller.class == OrdersController || controller.class == StoresController || controller.class == AddressesController
  end

  def search_page?
    params[:action] == 'search'
  end

  #
  # Converts Priority value (integer) into spefic CSS class name
  #
  def priorityClass(val)
    class_name = ''
    case val
      when 0
        class_name = ""
      when 1
        class_name = "warning"
      when 2
        class_name = "error"
    end
    class_name
  end

  #
  # Puts out Percentage Pill with colour according to the completion value
  #
  def percentagePill(num)
    class_name = ''
    case num
      when 0..25
        class_name = 'badge-important'

      when 26..85
        class_name = 'badge-warning'

      when 86..100
        class_name = 'badge-success'
    end

    html = raw('<span class="badge '+class_name+'">'+num.to_s+'%</span>')
  end

  #
  # Checks if the current URL matches the given one, and returns 'active' for CSS class
  #
  def active_class(path)
    cc = request.path.split('/')
    if path == 'dashboard' && request.path.length <= 1
      'active'
    else
      cc[1] =~ /#{path}/ ? 'active' : nil
    end
  end

  #
  # Add a link to a column title
  #
  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, url_for(params.merge(:sort => column, :direction => direction)) , {:class => css_class}
  end


end
