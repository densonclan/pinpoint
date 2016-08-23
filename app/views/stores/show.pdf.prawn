pdf.image store_jpg_logo(@store), at: [200, 800] if store_has_logo?(@store)
pdf.text "<font size='24'>Store #{@store.account_number}</font> <font size='16'><color rgb='#999999'>(#{@store.client.name})</color></font>", inline_format: true
pdf.move_down 20
pdf.table([
  ["Owner's name:", @store.owner_name], 
  ['Postcode:', @store.postcode],
  ['Account Number:', @store.account_number],
  ['Reference Number:', @store.reference_number],
  ['Business Manager:', @store.business_manager ?  @store.business_manager.name : ' None'],
  ['Preferred Distribution:', @store.preferred_distribution],
  ['Store Urgent:', @store.store_urgent ? 'Yes' : 'No']
], cell_style: {borders: [], padding: 3})

pdf.stroke_color '999999'

if @store.address
  pdf.move_down 10
  pdf.stroke_horizontal_rule
  pdf.move_down 10

  pdf.text "<font size='16'>Store Address</font>", inline_format: true
  pdf.move_down 10

  table = []
  table << [@store.address.address_type.titleize, 'Name:', @store.address.title + ' ' + @store.address.full_name]
  table << ['', 'Business:', @store.address.business_name] unless @store.address.business_name.blank?
  table << ['', 'Address:', full_address(@store.address)]
  table << ['', 'City:', @store.address.city] unless @store.address.city.blank?
  table << ['', 'County:', @store.address.county] unless @store.address.county.blank?
  table << ['', 'Postcode:', @store.address.postcode] unless @store.address.postcode.blank?
  table << ['', 'Email:', @store.address.email] unless @store.address.email.blank?
  table << ['', 'Phone:', @store.address.phone_number] unless @store.address.phone_number.blank?
  table << ['', '', '']
  pdf.table table, cell_style: {borders: [], padding: 2}
end

pdf.move_down 10
pdf.stroke_horizontal_rule
pdf.move_down 10
pdf.text "<font size='16'>Orders</font>", inline_format: true
pdf.move_down 10

if @store.orders.empty?
  pdf.text 'None'
else
  table = [['#', 'Status', 'Quantity', 'Boxes', 'Price', 'Page', 'Option', 'Period']] + 
    @store.orders.map do |o|
      [o.id, o.status_text, o.total_quantity, "#{o.total_boxes} (#{box_quantity(o)} per box)", "£#{number_with_precision(o.total_price, precision: 2)}", o.option && o.option.page ? o.option.page.name : '-', o.option ? o.option.name : '-', o.period ? o.period.period_number : '-']
    end
  pdf.table table
end

pdf.move_down 10
pdf.stroke_horizontal_rule
pdf.move_down 10
pdf.text "<font size='16'>Change Log</font>", inline_format: true
pdf.move_down 10

table = [['Change By', 'Date', 'Type', 'Changes']] +
  @store.versions.map do |v|
    [version_change_by(v), v.created_at.strftime('%d %b %Y %H:%M'), v.event, version_changes(v)]
  end
pdf.table table, column_widths: [80, 100, 60]