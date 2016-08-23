module PagesHelper

  def pages
    @pages ||= Page.ordered
  end

  def page_options
    options_from_collection_for_select(pages, :id, :name, params[:order_page])
  end
end