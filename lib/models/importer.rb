class Importer

  attr_accessor :errors, :success_count, :user

  def initialize(transport)
    @file = transport.spreadsheet
    @transport = transport
    @errors = []
    @user = transport.user
    @success_count = 0
  end

  def self.field_names_as_csv
    field_names.map {|f| f.titleize }.join(',')
  end

  def headers
    @headers ||= spreadsheet.row(1).map{ |c| (c || '').downcase.gsub(/\s/, '_') }
  end

  def import!
    (2..spreadsheet.last_row).each do |i|
      break if @transport.reload.cancelled?
      process_row Hash[[headers, spreadsheet.row(i)].transpose], i
    end
  end

  def valid?
    invalid_headers.empty?
  end

  def invalid_headers
    fn = self.class.field_names
    @invalid_headers ||= headers.reject {|header| header.blank? || fn.include?(header) }
  end

  def process_row(row, i)
    return if skip_row?(row)
    subject = find_or_create_object(row)
    subject.override_lock = true if subject.respond_to?(:override_lock=)
    subject.attributes = prepare_attributes row.slice(*model_class.accessible_attributes)
    set_extra_attributes(subject, row, i)
    if subject.save
      @success_count += 1
    else
      log_errors(subject, i)
    end
  end

  # allow overriding of whether to skip importing a row
  def skip_row?(row)
    false
  end

  # allow overriding of how existing objects are looked up
  def find_or_create_object(row)
    model_class.find_by_id(row["id"]) || model_class.new
  end

  def set_extra_attributes(subject, row, i)
    # overridden in subclasses
  end

  def set_client(subject, client, i)
    if client.blank?
      save_error i, 'Client name missing'
    else
      subject.client = Client.lookup(client)
      save_error i, "Invalid client name '#{client}'" if subject.client.nil?
    end
  end  

  def open_spreadsheet
    Roo::Spreadsheet.open(@file.path, {csv_options: {encoding: 'ISO-8859-1'}})
  end

  def spreadsheet
    @spreadsheet ||= open_spreadsheet
  end

  def log_errors(subject, row)
    save_error row, subject.errors.to_a.join(', ')
  end

  def save_error(row, error)
    @errors << Error.new(row, error)
  end

  def name
    model_class.name
  end

  def model_class
    raise 'Not implemented error'
  end

  def self.field_names
    raise 'Not implemented error'
  end

  def prepare_attributes(new_attributes)
    new_attributes = new_attributes.clone

    new_attributes.keys.each do |attr|
      case model_class.columns_hash[attr].type
      when :integer
        new_attributes[attr] = new_attributes[attr].to_s.gsub(/[,\s]+/, '')
      else
        new_attributes[attr] = new_attributes[attr]
      end
    end

    new_attributes
  end

  class Error
    def initialize(row, text)
      @row = row
      @text = text
    end

    attr_accessor :row, :text
  end
end