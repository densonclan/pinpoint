module BreadcrumbHelper

  def breadcrumbs(items = nil)
    content_tag(:ul, breadcrumb_items(items), class: 'breadcrumb')
  end

  def breadcrumb_items(items)
    items.nil? ? breadcrumb_item(['Dashboard']) : default_breadcrumb + items.map {|item| breadcrumb_item(item) }.join.html_safe
  end

  def default_breadcrumb
    breadcrumb_item(['Dashboard', root_path])
  end

  def breadcrumb_item(item)
    if item.length == 2
      content_tag(:li, breadcrumb_link_item(item))
    else
      content_tag(:li, item[0], class: 'active')
    end
  end

  def breadcrumb_link_item(item)
    link_to(item[0], item[1]) + content_tag(:span, '/', class: 'divider')
  end
end