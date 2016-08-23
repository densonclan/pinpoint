class Transport < ActiveRecord::Base
  belongs_to :user
  has_attached_file :spreadsheet
  attr_accessible :spreadsheet, :transport_type

  PENDING = 1
  WORKING = 2
  COMPLETE = 3
  CANCELLED = 4
  INVALID = 5
  ERRORED = 6

  before_validation :set_default_status, on: :create

  validates_presence_of :transport_type, :spreadsheet_file_name, :status
  validates_format_of :transport_type, with: /Address|BusinessManager|Client|Comment|Distributor|Option|Order|Page|Period|Store|PostcodeSector|ProofOfDelivery/

  scope :import_only, lambda { where('transport_type = ?', 'import') }
  scope :export_only, lambda { where('transport_type = ?', 'export') }
  scope :pending_imports, where('status=?', PENDING)
  scope :ordered, order('created_at DESC')

  def status_name
    case status
      when PENDING then return 'Pending'
      when WORKING then return 'Working'
      when COMPLETE then return 'Complete'
      when CANCELLED then return 'Cancelled'
      when INVALID then return 'Invalid'
      when ERRORED then return 'Errored'
      else return "Unknown (#{status})"
    end
  end

  def self.new_with_user(attributes, user)
    transport = Transport.new(attributes)
    transport.user = user
    transport
  end

  def cancel!
    update_attribute(:status, CANCELLED) unless complete?
  end

  def self.run_pending_imports
    pending_imports.each do |t|
      t.process!
    end
  end

  def pending?
    PENDING == status
  end

  def working?
    WORKING == status
  end

  def complete?
    COMPLETE == status
  end

  def cancelled?
    CANCELLED == status
  end

  def process!
    working!
    importer = importer_class.new(self)
    begin
      if importer.valid?
        importer.import!
        reload
        unless cancelled?
          send_email(importer)
          complete!
        end
      else
        invalid!
        send_invalid_email(importer)
      end
    rescue => e
      errored!
      send_errored_email(importer, e)
      Airbrake.notify(e, { severity: 'error' })
    end
  end

  def send_email(importer)
    ImportMailer.complete(importer).deliver
  end

  def send_errored_email(importer, exception)
    ImportMailer.errored(importer, exception).deliver
  end

  def send_invalid_email(importer)
    ImportMailer.invalid(importer).deliver
  end

  private

  def working!
    update_attribute(:status, WORKING)
  end

  def complete!
    update_attribute(:status, COMPLETE)
  end

  def errored!
    update_attribute(:status, ERRORED)
  end

  def invalid!
    update_attribute(:status, INVALID)
  end

  def importer_class
    Object.const_get("#{transport_type}Importer")
  end

  def set_default_status
    self.status = PENDING unless status
  end
end