module DistributorsHelper

  def distributors
    Distributor.ordered
  end

  def distributor_options
    options_from_collection_for_select distributors, :id, :name, params[:order_distributor]
  end

  def distributor_types
    Distributor.ordered.collect { |d| [ d.name, d.distributor_type ] }
    # [['In-Store','in-store'],['Solus','solus'],['Royal Mail', 'royal-mail'],['Newspaper','newspaper']]
  end

  def distribution_weeks(period = nil)
    [-2,-1,0,1,2].map {|week| [period ? distribution_week(period, week) : distribution_week_description(week), week]}
  end

  def distribution_total_boxes(distribution, page)
    return '-' if page.nil?
    (distribution.total_quantity.to_f / page.box_quantity).ceil
  end

  def distribution_leaflet(order, distribution)
    distribution.reference_number.blank? ? raw('&nbsp;') : "#{order.period.week_number + distribution.distribution_week}/#{distribution.reference_number}"
  end

  def distribution_week(period, week)
    period ? "#{distribution_week_description(week)} (w/c #{(period.date_promo + (week * 7)).strftime('%d %b %Y')})" : distribution_week_description(week)
  end

  def distribution_week_description(week)
    case week
     when -2 then return '2 Weeks before promo'
     when -1 then return 'Week before promo'
     when 0 then return 'Week of promo'
     when 1 then return 'Week after promo'
     when 2 then return '2 Weeks after promo'
      else return week
    end
  end

  def distribution_address(distribution)
    return 'none' if distribution.address.nil?
    full_address(distribution.address)
  end

  def publisher_address(distribution)
    return 'none' if distribution.publisher.nil?
    full_address(distribution.publisher)
  end
end