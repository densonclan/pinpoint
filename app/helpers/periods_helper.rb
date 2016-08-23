module PeriodsHelper

  def periods
    Period.accessible_by(current_user).ordered_for_form_selection
  end

  def export_periods
    Period.accessible_by(current_user).ordered_for_export
  end

  def period_options
    periods.includes(:client).decorate(context: {user: current_user})
  end

  def exporter_period_options
    export_periods.includes(:client).decorate(context: {user: current_user})
  end

  def client_period_count
    @clients.map {|c| c.periods.length }.reduce(:+)
  end

  def period_date(date)
    date ? date.strftime('%d %B %Y') : '-'
  end
end
