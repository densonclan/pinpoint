class Address < ActiveRecord::Base

  extend Filterable


  has_paper_trail

  STORE = 'store'
  ROYAL_MAIL = 'royal-mail'
  SOLUS = 'solus'
  NEWSPAPER = 'newspaper'

  before_validation :set_default_address_type
  before_validation :set_name_if_blank

  has_many :stores
  has_many :distributions

  scope :for_address_type, lambda { |address_type| where(address_type: address_type) unless address_type.blank? }
  scope :solus_and_newspaper, where("address_type = 'solus' OR address_type = 'newspaper'")
  scope :solus, where("address_type='solus'")
  scope :royal_mail, where("address_type='royal-mail'")
  scope :notstore, where("address_type!=?", STORE)
  scope :newspaper, where("address_type='newspaper'")
  scope :stores, where("address_type=?", STORE)
  scope :of_type, lambda {|type| where(address_type: type)}
  scope :ordered, order(:address_type, :full_name)

  scope :order_by, lambda {|column,direction| 
    column ||= 'address_type'
    direction ||= 'asc'
    order("#{column} #{direction}")
  }


  validates_presence_of :full_name
  validates :email, :email => true, :allow_blank => true

  attr_accessible :city, :county, :email, :first_line, :full_name, :mobile, :phone_number, :postcode, :second_line, :third_line, :title, :address_type, :business_name, :store_id, :store_addresses_attributes, :distribution_id, :publisher
  attr_accessor :updated_by, :distribution_id, :store_id, :publisher


   def self.filter(address_type = nil)
         self.for_address_type(address_type)
   end


  def store?
    address_type == STORE
  end

  def self.search(q, page = nil)
    where('business_name ILIKE ? OR full_name ILIKE ? OR county ILIKE ? OR city ILIKE ? OR postcode ILIKE ? OR first_line ILIKE ? OR second_line ILIKE ?', "%#{q}%", "%#{q}%", "%#{q}%", "%#{q}%", "%#{q}%", "%#{q}%", "%#{q}%").page(page)
  end

  def self.accessible_by(user)
    user.internal? ? where('1=1') : joins(:store).where('stores.client_id=?', user.client_id)
  end

  private

  def set_default_address_type
    self.address_type = STORE if address_type.blank?
  end

  def set_name_if_blank
    self.full_name = business_name if full_name.blank?
  end

  class Country

    attr_accessor :name, :counties

    def initialize(name, counties)
      @name = name
      @counties = counties
    end

    def to_s
      @name
    end

    class << self
      def england
        Country.new "England", [ "Avon", "Bedfordshire", "Berkshire", "Borders", "Bristol", "Buckinghamshire", "Cambridgeshire", "Channel Islands", "Cheshire", "Cleveland", "Cornwall", "Cumbria", "Derbyshire", "Devon", "Dorset", "Durham", "East Riding of Yorkshire", "East Sussex", "Essex", "Gloucestershire", "Greater Manchester", "Hampshire", "Herefordshire", "Hertfordshire", "Humberside", "Isle of Man", "Isle of Wight", "Isles of Scilly", "Kent", "Lancashire", "Leicestershire", "Lincolnshire", "London", "Merseyside", "Middlesex", "Norfolk", "North Yorkshire", "Northamptonshire", "Northumberland", "Nottinghamshire", "Oxfordshire", "Rutland", "Shropshire", "Somerset", "South Yorkshire", "Staffordshire", "Suffolk", "Surrey", "Tyne and Wear", "Warwickshire", "West Midlands", "West Sussex", "West Yorkshire", "Wiltshire", "Worcestershire" ]
      end

      def wales
        Country.new "Wales", [ "Blaenau Gwent", "Bridgend", "Caerphilly", "Cardiff", "Ceredigion", "Conwy", "Denbighshire", "Flintshire", "Gwynedd", "Isle of Anglesey", "Merthyr Tydfil", "Monmouthshire", "Neath Port Talbot", "Newport", "Pembrokeshire", "Powys", "Rhondda Cynon Taff", "Swansea", "The Vale of Glamorgan", "Torfaen", "Wrexham" ]
      end

      def scotland
        Country.new "Scotland", [ "Aberdeen City", "Aberdeenshire", "Angus", "Argyll and Bute", "Armagh", "Carmarthenshire", "Clackmannan", "Dumfries and Galloway", "East Ayrshire", "East Dunbartonshire", "East Lothian", "East Renfrewshire", "Edinburgh City", "Falkirk", "Fife", "Glasgow", "Highland", "Inverclyde", "Midlothian", "Moray", "North Ayrshire", "North Lanarkshire", "Orkney", "Perthshire and Kinross", "Renfrewshire", "Roxburghshire", "Shetland", "South Ayrshire", "South Lanarkshire", "Stirling", "West Dunbartonshire", "West Lothian", "Western Isles" ]
      end

      def northern_ireland
        Country.new "Northern Ireland", [ "Antrim", "Down", "Fermanagh", "Londonderry", "Tyrone" ]
      end
    end
  end  
end