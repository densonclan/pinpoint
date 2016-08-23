class ExcelSheet
  
  def initialize(sheet, fields)
    @sheet = sheet
    @fields = fields
    @totals = {}
  end

  def write_orders(orders, period, option = nil)
    write_sheet_title(period, option)
    write_header
    row = 2
    orders.each do |order|
      write_order_at(order, row)
      row += 1
    end
    write_totals_at(row)
    set_column_widths
  end

  def write_order_at(order, row)
    @sheet.row(row).height = 20
    @fields.each_with_index do |field, col|
      value = order.value(field)
      set_value(row, col, value)
      add_value_at_column(value, col) if sum_value_for_field?(field)
    end
  end

  def write_header
    @sheet.row(1).height = 20
    @fields.each_with_index do |value, col|
      @sheet[1, col] = value
      @sheet.row(1).set_format col, bold_format
    end
  end

  private

  def set_column_widths
    return if @fields.empty?
    @fields[0].size.times do |col|
      @sheet.column(col).width = max_column_width(col) * 1.8
    end
  end

  def max_column_width(column)
    width = 2
    (2..@fields.length+2).each do |row|
      row_width = @sheet[row, column].to_s.length
      width = row_width > width ? row_width : width
    end
    width
  end

  def write_sheet_title(period, option)
    @sheet[0,0] = sheet_title(period, option)
    @sheet.row(0).height = 20
    @sheet.row(0).set_format 0, title_format
  end

  def sheet_title(period, option)
    title = "#{period.client.name} Period #{period.period_number} #{period.year}"
    title += " - Option: #{option.name}" if option
    title
  end

  def write_totals_at(row)
    return if @totals.empty?
    set_value(row, 0, 'TOTAL')
    @totals.each do |col, value|
      @sheet[row, col] = value
      @sheet.row(row).set_format col, bold_format
    end
  end

  def title_format
    Spreadsheet::Format.new(left: nil, right: nil, top: nil, bottom: nil, font: Spreadsheet::Font.new("Arial", family: :swiss, weight: :bold, size: 14))
  end

  def bold_format
    Spreadsheet::Format.new(left: 'thin', right: 'thin', top: 'thin', bottom: 'thin', font: Spreadsheet::Font.new("Arial", family: :swiss, weight: :bold))
  end

  def sum_value_for_field?(field)
    field.include?('Total') || field.include?('Quantity')
  end

  def add_value_at_column(value, column)
    @totals[column] ||= 0
    @totals[column] += value.to_i
  end

  def set_value(row, col, value)
    @sheet[row, col] = value
    @sheet.row(row).set_format col, bordered_format
  end

  def bordered_format
    Spreadsheet::Format.new(left: 'thin', right: 'thin', top: 'thin', bottom: 'thin')
  end
end
