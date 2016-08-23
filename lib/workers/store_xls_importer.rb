class StoreXlsImporter

  def initialize(file_name)
    @file = File.open(file_name)
  end

  #Acc No  Company Reference Contact Address 1 Address 2 Address 3 Address 4 Address 5 Address 6 Store Postcode  Tel No  Print Qty Current Option  NI  Scot  Logo Ref  Comments
  def run
    ActiveRecord::Base.logger = nil
    (2..spreadsheet.last_row).each do |i|
      puts "Processing row #{i}"
      ExcelStoreRow.new(spreadsheet.row(i)).process
    end
  end

  class ExcelStoreRow
    def initialize(row)
      @row = row
    end

    def process
      @store = find_or_build_store
      @store.override_lock = true
      @store.account_number = @row[0].to_s.strip
      @store.reference_number = @row[2]
      @store.client = lookup_client
      address = find_or_create_address
      @store.address = address if address
      @store.logo = @row[16]
      @store.description = @row[17]
      puts "Saving store #{@store.account_number} success: #{success = @store.save}"
      puts "Error: #{@store.errors.full_messages.join(', ')}" unless success
    end

    private

    def find_or_build_store
      lookup_store || Store.new
    end

    def lookup_store
      Store.where(account_number: @row[0].to_s.strip).first
    end

    def lookup_client
      return costcutter if @row[1] == 'CC'
      return nisa if @row[1] == 'NISA'
      return select_and_save if @row[1] == 'S/S'
    end

    def find_or_create_address
      return nil if @row[3].blank? || @row[3].to_s == '.'
      lookup_address || create_address
    end

    def create_address
      address = Address.new
      address.full_name = @row[3] # contact
      address.business_name = @row[4] # address 1
      address.first_line = address_first_line # address 2
      address.second_line = @row[6] unless @row[6].to_s == '0' # address 3
      address.third_line = @row[7] # address 4
      address.city = @row[8] # address 5
      address.county = @row[9] # address 6
      address.postcode = @row[10] # store postcode
      address.phone_number = @row[11] # tel no
      address.address_type = Address::STORE
      puts "Saving address #{@row[3]} (#{@row[10]}) success: #{success = address.save}"
      puts "Error: #{address.errors.full_messages.join(', ')}" unless success
      address
    end

    def lookup_address
      Address.where(full_name: @row[3].to_s.strip, first_line: address_first_line, postcode: @row[10].to_s.strip).first
    end

    def address_first_line
      @row[5].blank? ? @row[4] : @row[5]
    end

    def costcutter
      client_named 'Costcutter'
    end

    def nisa
      client_named 'Nisa'
    end

    def select_and_save
      client_named 'Select and Save'
    end

    def client_named(name)
      Client.find_by_name(name)
    end

  end

  private

  def open_spreadsheet
    Roo::Spreadsheet.open(@file.path)
  end

  def spreadsheet
    @spreadsheet ||= open_spreadsheet
  end
end