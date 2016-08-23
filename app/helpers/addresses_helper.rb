module AddressesHelper

  def new_address_title
    return "Set address for store #{@store.account_number}" if @store
    return "Set publisher for #{@distribution.distributor.name.downcase} distribution" if @distribution && params[:publisher]
    return "Set address for #{@distribution.distributor.name.downcase} distribution" if @distribution
    "Add a new address"
  end

  def person_title_options
    ['Mr','Mrs','Miss']
  end

  def address_type_options
    [['Store', 'store'],['Royal Mail','royal-mail'],['Newspaper','newspaper'],['Solus','solus'],['Other','other']]
  end

  def address_type_filter_options
    options_for_select [['Store', 'store'],['Royal Mail','royal-mail'],['Newspaper','newspaper'],['Solus','solus'],['Other','other']], params[:type]
  end

  def address_filter_options
    options_for_select [['Solus and Newspaper Only',0],['Stores Only',1],['Solus Only',2],['Newspaper Only',3]], params[:type]
  end

  def english_counties
    [Address::Country.england, Address::Country.wales, Address::Country.scotland, Address::Country.northern_ireland]
  end

  def address_type_label(address)
    "#{address.address_type.capitalize} Address:"
  end

  def full_address(address)
    [address.business_name, address.full_name, address.first_line, address.postcode].reject {|a| a.blank? }.join(', ')
  end

  def copy_address_options
    selected = @distribution ? @distribution.address_id : nil
    options_for_select([['Select an address to copy', nil]]) + options_from_collection_for_select(copy_addresses, :id, :to_s, selected)
  end

  def copy_addresses
    if @distribution
      return Address.accessible_by(current_user).newspaper.ordered.decorate if @distribution.newspaper?
      return Address.accessible_by(current_user).solus.ordered.decorate if @distribution.solus_team?
      return Address.accessible_by(current_user).royal_mail.ordered.decorate if @distribution.royal_mail?
    end
    existing_store_addresses
  end

  def existing_store_addresses
    Address.accessible_by(current_user).stores.ordered.decorate
  end  

  def address_form_type_input(f)
    f.object.address_type = address_type_from_distribution if !f.object.address_type
    return f.input :address_type, as: :hidden if f.object.address_type
    f.input :address_type, collection: address_type_options
  end

  def address_lookup_path
    lookup_addresses_path(type: address_type_from_distribution)
  end

  def address_type_from_distribution
    return Address::STORE if @store
    return Address::STORE, Address::NEWSPAPER if @distribution && @distribution.newspaper?
    return Address::STORE, Address::ROYAL_MAIL if @distribution && @distribution.royal_mail?
    return Address::STORE, Address::SOLUS if @distribution && @distribution.solus_team?
    return Address::STORE, Address::SOLUS, Address::NEWSPAPER, Address::ROYAL_MAIL if @distribution && @distribution.store_delivery?
    nil
  end
end