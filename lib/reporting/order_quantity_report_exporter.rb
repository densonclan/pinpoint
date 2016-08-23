require 'spreadsheet'

class OrderQuantityReportExporter

  def initialize(order_quantity_reporter)
    @reporter = order_quantity_reporter
  end

  def file_name
    "order-quantity-report.xls"
  end

  def export
    generate_xls
    raw_data
  end

  private

  def generate_xls
    write_titles
    @reporter.options_with_orders.each do |option|
      write_option_row(option)
    end
  end

  def raw_data
    data = StringIO.new
    xls.write data
    data.string
  end

  def write_titles
    sheet[0,0] = "Option"
    sheet[0,1] = "Number of Boxes"
    sheet[0,2] = "Leaflet Quantity"
  end

  def write_option_row(option)
    @row ||= 1
    write_option_row_at(option, @row += 1)
  end

  def write_option_row_at(option, row)
    sheet[row,0] = option.name
    sheet[row,1] = orders_for_option_box_count(option)
    sheet[row,2] = orders_for_option_leaflet_count(option)
  end

  def orders_for_option_box_count(option)
    integer_val @reporter.orders_for_option_box_count(option)
  end

  def orders_for_option_leaflet_count(option)
    integer_val @reporter.orders_for_option_leaflet_count(option)
  end

  def integer_val(val)
    val.gsub(/,/, '').to_i
  end

  def xls
    @spreadsheet ||= Spreadsheet::Workbook.new
  end

  def sheet
    @sheet ||= xls.create_worksheet(name: 'Options')
  end

end