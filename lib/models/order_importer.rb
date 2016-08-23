# encoding: utf-8
class OrderImporter < Importer

  def model_class
    Order
  end

  def self.field_names
    names = %w(account_number period option total_price status)
    Distributor.all.each do |d|
      name = d.name.downcase.gsub(/\s/, '_')
      names += ["#{name}_total_quantity", "#{name}_notes", "#{name}_contract_number", "#{name}_reference_number", "#{name}_distribution_week"]
    end
    names
  end

  def skip_row?(row)
    row['option'].blank? || sum_totals(row) == 0
  end

  # find an order for the store in the current period
  def find_or_create_object(row)
    store = Store.find_by_account_number(row["account_number"])
    order = store.orders.for_current_period.first if store
    order ? order : Order.new(store: store, status: Order::AWAITING_PRINT)
  end  

  def set_extra_attributes(order, row, i)
    if order.store.nil?
      save_error i, "Store not found with account number #{row['account_number']}"
      return
    end
    order.updated_by = @user
    set_period(order, row['period'], i)
    set_option(order, row['option'], i)
    set_distributions(order, row)
    order.total_quantity = order.distributions.map {|d| d.total_quantity || 0}.reduce(:+)
  end

  def set_period(order, period_number, i)
    if period_number.blank?
      order.period = current_period_for(order.store.client_id)
    else
      order.period = Period.for_client(order.store.client_id).find_by_period_number period_number
      save_error i, "Unrecognised period number '#{period_number}' for #{order.store.client.name}. Valid values are: #{period_number_options(order.store.client_id)}" if order.period.nil?
    end
  end

  def period_number_options(client_id)
    Period.for_client(client_id).map {|p| p.period_number}.join(', ')
  end

  def current_period_for(client_id)
    current_periods.select {|p| p.client_id == client_id}.first
  end

  def current_periods
    @current_periods ||= Period.all_current
  end

  def set_option(order, option_name, i)
    if option_name.blank?
      save_error i, 'Option missing' 
    else
      order.option = Option.for_client(order.store.client_id).named(option_name).first
      save_error i, "Unrecognised option number '#{option_name}' for #{order.store.client.name}. Valid values are: #{option_options(order.store.client_id)}" if order.option.nil?
    end
  end

  def option_options(client_id)
    Option.names_for_client(client_id).join(', ')
  end

  def distributors
    @distributors ||= Distributor.all
  end

  def sum_totals(row)
    distributors.map do |distributor|
      name = distributor.name.downcase.gsub(/\s/, '_')
      row["#{name}_total_quantity"].to_i
    end.reduce(:+)
  end

  def set_distributions(order, row)
    distributors.each do |distributor|
      # Collect fields for d.name i.e. Solus - total quantity
      name = distributor.name.downcase.gsub(/\s/, '_')
      if row["#{name}_total_quantity"].to_i > 0
        distribution = distribution_for_order(order, distributor.id)
        distribution.total_quantity = row["#{name}_total_quantity"].to_i
        distribution.reference_number = extract_reference_number(row["#{name}_reference_number"])
        distribution.contract_number = row["#{name}_contract_number"]
        distribution.notes = row["#{name}_notes"]
        distribution.distribution_week = distribution_week(order, row['#{name}_distribution_week'])
      end
    end
  end

  def extract_reference_number(s)
    return nil if s.blank?
    match = s.match /([\d]+)\/([\d]+)/
    match ? match[2] : s
  end

  def distribution_for_order(order, distributor_id)
    order.distributions.select {|d| d.distributor_id == distributor_id}.first || order.distributions.build(distributor_id: distributor_id)
  end

  def distribution_week(order, date_string)
    dist_date = extract_distribution_date_from_string(date_string)
    return nil if dist_date.nil?
    ((dist_date - order.period.date_promo) / 7).round
  end

  # w/c 9th September 2013 (Thurs to Fri)
  def extract_distribution_date_from_string(s)
    return nil if s.blank?
    begin
      return DateTime.strptime s.gsub('w/c', '').gsub(/\([\w ]*\)/, '').gsub(/([\d])[stndrh]{2}/, '\1').strip, '%d %B %Y'
    rescue
    end
    nil
  end
end