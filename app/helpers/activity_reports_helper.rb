module ActivityReportsHelper

  def activity_search_users
    options_from_collection_for_select User.accessible_by(current_user).ordered, :id, :name, params[:updated_by]
  end

  def report_activity_type_class(type)
    params[:type] == type ? 'active' : nil
  end

  def report_activity_orders?
    params[:type] != 'stores'
  end

  SKIP_AUDIT_FIELDS = %w(id user_id created_at updated_at updated_by_id logotype_id)

  def object_changes(object)
    version_changes object.versions.last
  end

  def version_changes(version)
    changeset = version.changeset
    describe_changes(version.event, changeset.blank? ? manual_object_changes(version.item, version.previous ? version.previous.item : nil) : selected_changeset_attributes(changeset))
  end

  def version_change_by(version)
    (version.whodunnit && user = User.find_by_id(version.whodunnit)) ? user.name : '-'
  end

  def manual_object_changes(object, previous)
    changes = changed_attributes(object, previous)
    changes.each do |k,v|
      changes[k] = [previous ? previous.attributes[k] : nil, v]
    end
    changes
  end

  def changed_attributes(object, previous)
    object.attributes.select {|k,v| !SKIP_AUDIT_FIELDS.include?(k) && (previous == nil || previous.attributes[k] != v)}
  end

  def selected_changeset_attributes(changeset)
    changeset.select {|k,v| !SKIP_AUDIT_FIELDS.include?(k)}
  end

  def describe_changes(event, hash)
    hash.keys.map do |k|
      describe_change(event, k, hash[k])
    end.join(", \n")
  end

  def describe_change(event, key, vals)
    event == 'create' ?
      "#{describe_key(key)} set to #{describe_val(key, vals[1])}" : 
      "#{describe_key(key)} changed from #{describe_val(key, vals[0])} to #{describe_val(key, vals[1])}"
  end

  def describe_key(key)
    case key
      when 'page_id' then return 'Page'
      when 'option_id' then return 'Option'
      when 'client_id' then return 'Client'
      when 'store_id' then return 'Store'
      when 'period_id' then return 'Period'
      when 'business_manager_id' then return 'Business Manager'
      else return key.gsub(/_/, ' ').capitalize
    end
  end

  def describe_val(key, val)
    return 'nil' if val.nil?
    begin
      case key
        when 'page_id' then return Page.find(val).name
        when 'option_id' then return Option.find(val).name
        when 'client_id' then return client_name_with_id(val)
        when 'business_manager_id' then return business_manager_name_with_id(val)
        when 'period_id' then return Period.find(val).period_number
        when 'store_id' then return Store.find(val).account_number
        when 'status' then return Order.status_text(val)
        else return val
      end
    rescue
    end
    return 'unknown'
  end

  def client_name_with_id(id)
    @clients ||= Client.all
    @clients.select {|c| c.id == id.to_i}.first.name
  end

  def business_manager_name_with_id(id)
    @bms ||= BusinessManager.all
    @bms.select {|b| b.id == id.to_i}.first.name
  end
end