class StoreExporter

  def initialize(user, params)
    @user = user
    @params = params
  end

  def export
    write_stores
    raw_data
  end

  private

  def write_stores
    write_titles
    stores.each_with_index {|store, index| write_store_at(store, index+1)}
  end

  def stores
    apply_filter\
    .includes(:address, :client)\
    .accessible_by(@user)\
    .for_client(@params[:client])\
    .for_business_manager(@params[:business_manager])\
    .for_county(@params[:county])\
    .search(@params[:query])\
    .order_by(@params[:sort], @params[:direction])
  end

  def apply_filter
    case @params[:type]
      when 'participating' then return Store.participating
      when 'nologo' then return Store.nologo
      when 'noorders' then return Store.noorders
      else return Store.scoped
    end
  end

  def write_titles
    sheet.row(0).concat ['ID', 'Account Number', 'Reference Number', 'Owner', 'Description', 'Postcode', 'Client', 'Address']
  end

  def write_store_at(store, row)
    sheet.row(row).concat row_for_store(store)
  end

  def row_for_store(store)
    [store.id,
      store.account_number,
      store.reference_number,
      store.owner_name,
      store.description,
      store.postcode,
      store.client.try(:name),
      display_address(store.address)
    ]
  end

  def display_address(address)
    return '' unless address
    address_fields(address).reject {|f| f.nil? || f.strip.blank? }.join("\n")
  end

  def address_fields(address)
    [address.title, address.full_name, address.business_name, address.first_line, address.second_line, address.third_line, address.city, address.county, address.postcode]    
  end

  def raw_data
    data = StringIO.new
    xls.write data
    data.string
  end

  def xls
    @spreadsheet ||= Spreadsheet::Workbook.new
  end

  def sheet
    @sheet ||= xls.create_worksheet(name: 'Stores')
  end

end