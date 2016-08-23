#encoding: utf-8
namespace :bargain_booze do

  desc 'Import bargain booze products'
  task :import_products => :environment do
    file   = Rails.root + 'data/bargain_booze/products.csv'
    client = Client.find_by_name('Bargain Booze')

    CSV.foreach(file) do |row|
      if row[0].to_i > 0
        product = Product.find_or_initialize_by_id(row[0])

        product.client      = client
        product.name        = row[1].strip
        product.description = row[2]
        product.bottles     = row[3].to_s.match(/bot/i).present?
        product.fridge      = row[4].present?

        product.save!
      end
    end
  end

  desc 'Export buyers sheets'
  task :export => :environment do
    file  = Rails.root + 'data/bargain_booze/import.csv'
    output = []

    output << ['Promo code', 'Code', 'Description', 'Description 1', 'Type', 'Single Retail', 'Was Price', 'Price Marked', 'RRP', 'Saving',
               'Multibuy 1', 'Multibuy 2', 'Multibuy 3', 'Multibuy 4', 'Mix & Match', 'Buy One Get One Free', 'Small Barker Style',
               'Medium Barker Style', 'Large Barker Style', 'Additional Info', 'Quantity Required', 'Buying', 'w/s']

    CSV.foreach(file, "r:windows-1250") do |row|
      if row[7].present? && row[7] != 'Description'

        code = row[5]

        # TODO: Look up from products list
        description = row[7]
        description_1 = row[8]

        single_retail = row[42]
        puts "--- single retail: #{single_retail}"

        saving = row[43].to_f - single_retail.to_f

        was_price = saving_value = nil
        if saving > 0
          was_price = row[43]
          saving_value = saving.round(2)
          puts "--- was price: #{row[43]}"
          puts "--- saving: #{saving.round(2)}"
        end

        deal_1 = deal_2 = deal_3 = deal_4 = ''
        deal_1 = "#{row[38]} for £#{row[44]}" if row[44].present?
        deal_2 = "#{row[39]} for £#{row[45]}" if row[45].present?
        deal_3 = "#{row[40]} for £#{row[46]}" if row[40].present?
        deal_4 = "#{row[41]} for £#{row[47]}" if row[47].present?

        if row[44].present?
          puts "--- deal 1: #{row[38]} for £#{row[44]}"
        end

        if row[45].present?
          puts "--- deal 2: #{row[39]} for £#{row[45]}"
        end

        if row[46].present?
          puts "--- deal 3: #{row[40]} for £#{row[46]}"
        end

        if row[47].present?
          puts "--- deal 4: #{row[41]} for £#{row[47]}"
        end

        puts row.to_s

        output << [nil, code, description, description_1, 'Type', 'Single Retail', was_price, 'Price Marked', 'RRP', saving_value,
                   deal_1, deal_2, deal_3, deal_4, 'Mix & Match', 'Buy One Get One Free', 'Small Barker Style',
                   'Medium Barker Style', 'Large Barker Style', 'Additional Info', 'Quantity Required', 'Buying', 'w/s']

      end
    end

    puts output.inspect

  end

end
