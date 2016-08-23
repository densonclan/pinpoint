#encoding: utf-8
require 'spreadsheet'

class BargainBoozeExporter

  def initialize(spreadsheet)
    @import_file = spreadsheet.open
    @options = %w{ BB TG WR BBWH SCOTBB SCOTWR GT }
    @fields = ['Promo code', 'Code', 'Description', 'Description 1', 'Single Retail', 'Was Price', 'Price Marked', 'RRP', 'Saving',
               'Multibuy 1', 'Multibuy 2', 'Multibuy 3', 'Multibuy 4', 'Mix & Match', 'Buy One Get One Free', 'Small Barker Style',
               'Medium Barker Style', 'Large Barker Style', 'Additional Info', 'Quantity Required', 'Buying', 'w/s', 'Retro single', 'Retro Deal 1',
               'Retro Deal 2', 'Retro Deal 3', 'Retro Deal 4', 'Margin single', 'Margin Deal 1', 'Margin Deal 2', 'Margin Deal 3', 'Margin Deal 4']
  end

  def export
    write_orders
    raw_data
  end

  def write_orders
    @options.each do |option|
      write_orders_for_option(option)
    end
    sheet_for_option(@options.first) if xls.worksheets.empty? # handle no orders
  end

  def sheet_for_option(option)
    BargainBoozeSheet.new( @import_file, xls.create_worksheet(name: option), @fields )
  end

  def write_orders_for_option(option)
    sheet_for_option(option).write_orders(option)
  end

  def xls
    @spreadsheet ||= Spreadsheet::Workbook.new
  end

  def raw_data
    data = StringIO.new
    xls.write data
    data.string
  end

end

class BargainBoozeSheet

  def initialize(import_file, sheet, fields)
    @import_file = import_file
    @sheet = sheet
    @fields = fields
    @totals = {}
  end

  def write_orders(option)
    write_sheet_title(option)
    write_header

    row_count = 2

    CSV.foreach(@import_file, encoding: 'ISO-8859-1') do |row|
      if row[7].present? && row[7] != 'Description' && row[9].to_s.match(/yes/i).present?

        code = row[5]
        product = Product.find_by_id(code)

        if product.present?
          name = product.name
          description = product.description
        else
          name = row[7]
          description = ''
        end

        single_retail = row[42]
        saving = row[43].to_f - single_retail.to_f

        was_price = saving_value = nil
        if saving > 0
          was_price = row[43]
          saving_value = saving.round(2)
        end

        column_counters = brand_column_matchers(option)
        deal_1 = deal_2 = deal_3 = deal_4 = ''
        deal_1 = "#{row[column_counters[0][0]].to_i} #{container_type(product).to_s.upcase} FOR £#{row[column_counters[0][1]]}" if row[column_counters[0][1]].present? && row[column_counters[0][0]].to_i != 1
        deal_2 = "#{row[column_counters[1][0]].to_i} #{container_type(product).to_s.upcase} FOR £#{row[column_counters[1][1]]}" if row[column_counters[1][1]].present? && row[column_counters[1][0]].to_i != 1
        deal_3 = "#{row[column_counters[2][0]].to_i} #{container_type(product).to_s.upcase} FOR £#{row[column_counters[2][1]]}" if row[column_counters[2][1]].present? && row[column_counters[2][0]].to_i != 1
        deal_4 = "#{row[column_counters[3][0]].to_i} #{container_type(product).to_s.upcase} FOR £#{row[column_counters[3][1]]}" if row[column_counters[3][1]].present? && row[column_counters[3][0]].to_i != 1

        retro_counters = retro_column_matchers(option)
        retro_s = retro_1 = retro_2 = retro_3 = retro_4 = ''
        retro_s = row[retro_counters[0]]
        retro_1 = row[retro_counters[1]]
        retro_2 = row[retro_counters[2]]
        retro_3 = row[retro_counters[3]]
        retro_4 = row[retro_counters[4]]

        margin_counters = margin_column_matchers(option)
        margin_s = margin_1 = margin_2 = margin_3 = margin_4 = ''
        margin_s = row[margin_counters[0]]
        margin_1 = row[margin_counters[1]]
        margin_2 = row[margin_counters[2]]
        margin_3 = row[margin_counters[3]]
        margin_4 = row[margin_counters[4]]

        values = [nil, code, name, description, single_retail, was_price, nil, nil, saving_value, deal_1, deal_2, deal_3,
                  deal_4, nil, nil, small_barker_value(row, was_price, [deal_1, deal_2, deal_3, deal_4]), nil,nil, nil, barker_count(product),
                  row[21], row[30], retro_s, retro_1, retro_2, retro_3, retro_4, margin_s, margin_1, margin_2, margin_3, margin_4]

        write_order_at(values, row_count)
        row_count += 1
      end
    end

    set_column_widths

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

    def write_sheet_title(option)
      @sheet[0,0] = option
      @sheet.row(0).height = 20
      @sheet.row(0).set_format 0, title_format
    end

    def write_header
      @sheet.row(1).height = 20
      @fields.each_with_index do |value, col|
        @sheet[1, col] = value
        @sheet.row(1).set_format col, bold_format
      end
    end

    def title_format
      Spreadsheet::Format.new(left: nil, right: nil, top: nil, bottom: nil, font: Spreadsheet::Font.new("Arial", family: :swiss, weight: :bold, size: 14))
    end

    def bold_format
      Spreadsheet::Format.new(left: 'thin', right: 'thin', top: 'thin', bottom: 'thin', font: Spreadsheet::Font.new("Arial", family: :swiss, weight: :bold))
    end

    def write_order_at(record, row)
      @sheet.row(row).height = 20
      @fields.each_with_index do |field, col|
        set_value(row, col, record[col])
      end
    end

    def set_value(row, col, value)
      @sheet[row, col] = value
      @sheet.row(row).set_format col, nil
    end

    #def bordered_format
    #  Spreadsheet::Format.new(left: 'thin', right: 'thin', top: 'thin', bottom: 'thin')
    #end

    def container_type(product)
      if product.present?
        product.bottles? ? 'Bottles' : 'Cans'
      end
    end

    def barker_count(product)
      if product.present?
        product.fridge? ? 2 : 1
      end
    end

    def small_barker_value(row, was_price, deals_array)
      #if row[9].to_s.match(/new/i).present?
      #  'NEW'
      #elsif was_price.present? || deals_array.reject { |d| d.blank? }.present?
      #  'RED'
      #else
      #  'EDLP'
      #end
      if row[6].to_s.match(/new/i).present?
        'NEW'
      else
        'RED'
      end
    end

    def brand_column_matchers(option)
      {
        'BB'     => [[38, 44], [39, 45], [40, 46], [41, 47]],
        'TG'     => [[38, 49], [39, 50], [40, 51], [41, 52]],
        'WR'     => [[38, 55], [39, 56], [40, 57], [41, 58]],
        'BBWH'   => [[38, 60], [39, 61], [40, 62], [41, 63]],
        'SCOTBB' => [[38, 65], [39, 66], [40, 67], [41, 68]],
        'SCOTWR' => [[38, 70], [39, 71], [40, 72], [41, 73]],
        'GT'     => [[38, 75], [39, 76], [40, 77], [41, 78]],
      }[option]
    end

    def retro_column_matchers(option)
      {
          'BB'     => [79,  80,  81,  82,  83],
          'TG'     => [84,  85,  86,  87,  88],
          'WR'     => [89,  90,  91,  92,  93],
          'BBWH'   => [94,  95,  96,  97,  98],
          'SCOTBB' => [99,  100, 101, 102, 103],
          'SCOTWR' => [104, 105, 106, 107, 108],
          'GT'     => [109, 110, 111, 112, 113],
      }[option]
    end

    def margin_column_matchers(option)
      {
          'BB'     => [119, 120, 121, 122, 123],
          'TG'     => [124, 125, 126, 127, 128],
          'WR'     => [129, 130, 131, 132, 133],
          'BBWH'   => [134, 135, 136, 137, 138],
          'SCOTBB' => [139, 140, 141, 142, 143],
          'SCOTWR' => [144, 145, 146, 147, 148],
          'GT'     => [149, 150, 151, 152, 153],
      }[option]
    end

end
