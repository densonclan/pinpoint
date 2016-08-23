module Filterable

  def filter(params, user)
    o = accessible_by(user)
    o = o.for_status(params[:order_status]) if search_param?(params[:order_status])
    o = o.for_option(params[:order_option]) if search_param?(params[:order_option])
    o = o.for_distribution(params[:order_distributor]) if search_param?(params[:order_distributor])
    o = o.for_period(params[:order_period]) if search_param?(params[:order_period])
    o
  end

  def search_param?(param)
    !param.nil? && !param.empty? && param.is_a?(Array) && !param[0].blank?
  end
end