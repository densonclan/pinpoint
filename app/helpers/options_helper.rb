module OptionsHelper

  def options
    @options_helper_options ||= Option.for_listing.accessible_by(current_user).ordered.decorate(context: {user: current_user})
  end

  def option_options
    options_from_collection_for_select(options, :id, :name, params[:order_option])
  end

  def option_price_zones
    ['Convenience', 'Forecourt', 'High Street', 'Off Licence', 'Supermarket' ]
  end

  def display_option_value_year?(option_value)
    disp = option_value.period.year != @last_year
    @last_year = option_value.period.year
    disp
  end
end