class Distribution < ActiveRecord::Base
  has_paper_trail

  before_validation :set_distribution_week, :convert_postcode_ids, :set_ship_via_nil_if_blank
  belongs_to :order
  belongs_to :distributor
  belongs_to :address
  belongs_to :publisher, class_name: 'Address'
  has_many :distribution_postcodes, autosave: true, dependent: :destroy
  has_many :postcode_sectors, through: :distribution_postcodes

  scope :ordered, order('id ASC')

  IN_STORE   = 1
  SOLUS_TEAM = 2
  ROYAL_MAIL = 3
  NEWSPAPER  = 4
  STORE_OWN_DELIVERY = 5

  SHIP_VIA_GH = 'G&H'
  SHIP_VIA_NEP = 'NEP'
  SHIP_VIA_STORE = 'STORE'

  validates_length_of :contract_number, :maximum => 255
  validates_length_of :reference_number, :maximum => 255
  validates_length_of :notes, :maximum => 255
  validates_inclusion_of :ship_via, in: [SHIP_VIA_NEP, SHIP_VIA_GH, SHIP_VIA_STORE], allow_nil: false, message: 'is required'
  validates_numericality_of :total_quantity, greater_than: 0, only_integer: true
  validates_numericality_of :distribution_week, greater_than_or_equal_to: -2, less_than_or_equal_to: 2, only_integer: true, message: 'must be the between 2 weeks prior and 2 weeks after promotion'

  attr_accessible :contract_number, :distributor_id, :notes, :reference_number, :total_quantity, :distribution_week, :postcode_ids, :ship_via, :address_id, :publisher_id
  attr_accessor :postcode_ids

  extend Filterable

  scope :filter_periods, lambda {|periods| where('order_id IN (SELECT id FROM orders WHERE period_id IN (?))', periods.map{|p| p.id}) }
  scope :for_period, lambda {|id| where('order_id IN (SELECT id FROM orders WHERE period_id IN (?))', id) }
  scope :for_current_period, where('order_id IN (SELECT id FROM orders WHERE period_id IN (SELECT id FROM periods WHERE current = ?))', true)
  scope :for_status, lambda {|array| where('order_id IN (SELECT id FROM orders WHERE status IN (?))', array) }
  scope :for_ship_via, lambda {|array| where('ship_via IN (?)', array)}
  scope :for_participation_only_stores, joins(order: :store).where('stores.participation_only=?', true)
  scope :for_option, lambda  {|array| where('order_id IN (SELECT id FROM orders WHERE option_id IN (?))', array) }
  scope :for_distribution, lambda {|array| where(distributor_id: array) }
  scope :for_store, lambda {|store_id| where('order_id IN (SELECT id FROM orders WHERE store_id=?)', store_id) }
  scope :for_store_having_personalised_panel, lambda { where('stores.personalised_panel_1 = ? or stores.personalised_panel_2 = ? or stores.personalised_panel_3 = ?', true, true, true) }
  scope :for_store_having_generic_panel, lambda { where('stores.personalised_panel_1 = ? or stores.personalised_panel_2 = ? or stores.personalised_panel_3 = ?', false, false, false) }


  def changed?
    super || postcode_ids_array.sort != distribution_postcodes.map {|d| d.postcode_sector_id}.sort
  end

  def store_delivery?
    distributor_id == IN_STORE
  end

  def store_own_delivery?
    distributor_id == STORE_OWN_DELIVERY
  end

  def royal_mail?
    distributor_id == ROYAL_MAIL
  end

  def newspaper?
    distributor_id == NEWSPAPER
  end

  def solus_team?
    distributor_id == SOLUS_TEAM
  end

  def week_prior?
    distribution_week == -1
  end

  def residential_total
    postcode_sectors.map {|p| p.residential}.reduce :+
  end

  def business_total
    postcode_sectors.map {|p| p.business}.reduce :+
  end

  def total
    residential_total + business_total
  end

  def self.accessible_by(user, action = 'ignored')
    user.internal? ? where('1=1') : where("order_id IN (SELECT o.id FROM orders o INNER JOIN stores s ON o.store_id=s.id WHERE s.client_id=?)", user.client_id)
  end

  def calculate_box_count(page = nil)
    page = page.nil? ? order.page : page
    page && page.box_quantity ? (total_quantity.to_f / page.box_quantity.to_f).ceil : nil
  end

  private

  def set_distribution_week
    self.distribution_week = 0 if !distribution_week
  end

  def convert_postcode_ids
    postcode_ids_array.each {|id| build_postcode(id) unless has_postcode?(id) }
    distribution_postcodes.each {|dp| dp.mark_for_destruction unless postcode_ids_array.include?(dp.postcode_sector_id)}
  end

  def postcode_ids_array
    @postcode_ids_array ||= postcode_ids ? postcode_ids.split(',').map{|i| i.to_i} : []
  end

  def has_postcode?(id)
    distribution_postcodes.any? {|dp| dp.postcode_sector_id == id}
  end

  def build_postcode(id)
    distribution_postcodes.build postcode_sector_id: id
  end

  def set_ship_via_nil_if_blank
    self.ship_via = nil if ship_via.blank?
  end
end