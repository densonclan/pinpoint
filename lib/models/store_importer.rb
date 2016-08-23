class StoreImporter < Importer

  def model_class
    Store
  end

  def self.field_names
    %w(account_number reference_number preferred_distribution client business_manager logo participation_only preferred_option full_name first_line second_line third_line city postcode county phone_number email)
  end

  def find_or_create_object(row)
    Store.find_by_account_number(row["account_number"]) || Store.new_with_user(nil, @user)
  end

  def set_extra_attributes(store, row, i)
    set_client(store, row['client'], i)
    return if store.client_id.blank?
    store.owner_name = 'unknown' if store.owner_name.blank?
    set_address(store, row)
    set_all_comments(store, row)
    set_business_manager(store, row['business_manager'], i)
    set_preferred_option(store, row['preferred_option'], i)
  end

  def set_all_comments(store, row)
    row.keys.select {|key| key =~ /comment/}.each do |key|
      set_comment(store, row[key])
    end
  end

  def set_comment(store, text)
    return if text.blank? || store.comments.any?{|c| c.full_text == text} # avoid creating duplicate comments
    comment = store.comments.build
    comment.full_text = text
    comment.user = user
  end

  def set_preferred_option(store, option, i)
    return if option.blank?
    store.preferred_option = Option.for_client(store.client.id).named(option).first
    save_error i, "Unrecognised option '#{option}' for #{store.client.name}." if store.preferred_option.nil?
  end

  def find_or_build_address(store)
    store.address ||= Address.new(address_type: Address::STORE)
  end

  def set_address(store, row)
    return if row['full_name'].blank?
    address = find_or_build_address(store)
    %w(full_name first_line second_line third_line city postcode county phone_number email).each do |field|
      address.send("#{field}=".to_sym, row[field])
    end
  end

  def set_client(store, client, i)
    if client.blank?
      save_error i, 'Client name missing'
    else
      store.client = client_named(client)
      save_error i, "Invalid client '#{client}'" if store.client.nil?
    end
  end

  def set_business_manager(store, business_manager, i)
    return if business_manager.blank?
    business_manager = business_manager.to_s
    store.business_manager = BusinessManager.for_client(store.client_id).find_by_name_case_insensitive(business_manager)
    store.business_manager = BusinessManager.new(client_id: store.client_id, name: business_manager) if store.business_manager.nil?
  end

  private
  def client_named(client)
    clients.select {|c| c.name == client.downcase }.first
  end

  def clients
    @clients ||= Client.all.each {|c| c.name.downcase!}
  end
end