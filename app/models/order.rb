class Order < ActiveRecord::Base
  has_paper_trail

  AWAITING_PRINT = 0
  IN_PRINT = 2
  DISPATCHED = 3
  COMPLETED = 1

  has_many :distributions, dependent: :destroy, autosave: true
  has_many :distributors, :through => :distributions
  has_many :comments, :as => :commentable, :dependent => :destroy
  has_many :order_exceptions, dependent: :destroy

  belongs_to :user
  belongs_to :updated_by, :class_name => "User"
  belongs_to :store
  belongs_to :option
  belongs_to :period
  
  extend AccessibleBy
  extend Filterable
  include Lockable

  scope :for_store, lambda { |store| where(store_id: store) unless store.blank? }
  scope :for_status, lambda { |status| where(status: status) unless status.blank? }
  scope :for_option, lambda { |option_id| where(option_id: option_id) unless option_id.blank? }
  scope :for_period, lambda {|period_id| where(period_id: period_id) unless period_id.blank? }
  scope :for_manager, lambda { |id| joins(:store).where('stores.business_manager_id=?', id) }
  scope :for_listing, includes(:distributors, :option, {:period => :client}, {:store => :client})
  scope :for_reporting, includes(:distributions, :option)#{:option => {:values => :page}})
  scope :for_review_list, includes(:store, :option, :order_exceptions)
  scope :for_activity_list, includes({:store => :client}, :updated_by, :versions)
  scope :updated_by, lambda {|user_id| where('updated_by_id = ?', user_id) unless user_id.blank? }
  scope :updated_before, lambda {|date| where('updated_at < ?', date) unless date.blank? }
  scope :updated_after, lambda {|date| where('updated_at > ?', date) unless date.blank? }
  scope :ordered, order(:id) # for now
  scope :reverse_update_order, order('updated_at DESC')
  scope :with_distributions, includes(:distributions)
  scope :awaiting_print, for_status(AWAITING_PRINT)
  scope :in_print, for_status(IN_PRINT)
  scope :dispatched, for_status(DISPATCHED)
  scope :completed, for_status(COMPLETED)

  scope :order_by, lambda {|column,direction| 
    column ||= 'orders.updated_at'
    direction ||= 'desc'
    order("#{column} #{direction}")
  }
  scope :count_by_manager, joins(:store).select("stores.business_manager_id AS id, stores.client_id AS client_id, COUNT(*) AS total_quantity").group("stores.business_manager_id, stores.client_id")
  scope :count_by_period, select("period_id, COUNT(*) AS total_quantity").group("period_id")

  scope :filter_periods, lambda {|periods| where('period_id IN (?)', periods.map{|p| p.id}) }
  scope :for_current_period, where("period_id IN (SELECT id FROM periods WHERE current = ?)", true)
  scope :for_previous_period, ->(user) {
    where(period_id: (user.client.periods.all_current.first.previous_period rescue nil))
  }
  scope :for_next_period, ->(user) {
    where(period_id: (user.client.periods.all_current.first.next_period rescue nil))
  }
  scope :for_distribution, lambda {|array| includes(:distributions).where('distributions.distributor_id IN (?)', array)}
  scope :for_ship_via, lambda {|array| includes(:distributions).where('distributions.ship_via IN (?)', array)}
  scope :for_participation_only_stores, joins(:store).where('stores.participation_only=?', true)
  scope :matching_account_number, lambda {|account_number| joins(:store).where('stores.account_number ILIKE ?', "%#{account_number}%") unless account_number.blank? }
  scope :for_store_without_logo, joins(:store).where("logo='' OR logo IS NULL")

  validates :total_quantity, :presence => true, :numericality => { :greater_than => 0 }
  validates_numericality_of :total_price
  # validates :distribution_week, :presence => true, :numericality => { :less_than => 4 }
  validates_numericality_of :status, greater_than_or_equal_to: AWAITING_PRINT, less_than_or_equal_to: DISPATCHED, only_integer: true
  validates_presence_of :store_id, :option_id
  validate :option_belongs_to_client, :period_belongs_to_client

  accepts_nested_attributes_for :distributions, :reject_if => lambda { |a| a[:total_quantity].to_i == 0 }, :allow_destroy => true
  accepts_nested_attributes_for :comments, :reject_if => lambda { |a| a[:full_text].blank? }, :allow_destroy => true
  attr_accessible :distributions_attributes, :comments_attributes, :distribution_week, :status, :total_price, :total_quantity, :user_id, :store_id, :period_id, :option_id, :account_number, :store
  attr_accessor :account_number

  def skipped_in_period?(period)
    order_exceptions.select {|e| e.period_id == period.id}.first
  end

  def self.accessible_by(user, action = 'ignored')
    user.internal? ? scoped : where("store_id IN (SELECT id FROM stores WHERE client_id=?)", user.client_id)
  end

  # finds all orders which match another order with the same store ID and period ID
  def self.duplicates
    # this is my least-favourite code....
    results = connection.select_all 'SELECT store_id, period_id, COUNT(*) FROM orders GROUP BY store_id, period_id HAVING COUNT(*) > 1'
    sql = ""
    results.each do |r|
      sql += "(store_id=#{r['store_id']} AND period_id=#{r['period_id']}) OR "
    end
    includes(:distributors, :option, {:period => :client}, {:store => :client}).where(sql[0..-5])
  end

  def self.smallest
    order("total_quantity").first
  end

  def self.largest
    order("total_quantity DESC").first
  end

  def self.latest
    order('period_id DESC').last
  end

  #
  # Check if given order has a distribution
  #
  def has_distribution?
    distributors.any?{|d| !d.in_store? }
  end

  def self.search(query, page = nil)
    joins('INNER JOIN stores ON orders.store_id=stores.id LEFT OUTER JOIN options ON orders.option_id=options.id')\
    .where('stores.owner_name ILIKE ? OR stores.account_number ILIKE ? OR options.name LIKE ? OR orders.id IN (SELECT d.order_id FROM distributions d INNER JOIN addresses a ON d.address_id=a.id WHERE a.full_name ILIKE ? OR a.first_line ILIKE ? OR a.second_line ILIKE ? OR a.third_line ILIKE ? OR a.city ILIKE ? OR a.postcode ILIKE ? OR a.business_name ILIKE ?)', \
      "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%")\
    .page page
  end

  def self.update_status_for_option(option, status)
    ids = Order.for_current_period.for_option(option.id).map {|o| o.id}
    Order.where('id IN (?)', ids).update_all(status: status) if ids.length > 0
  end

  def status_text
    Order.status_text(status)
  end

  def self.status_text(status)
    case status
      when AWAITING_PRINT then return 'Awaiting Print'
      when COMPLETED then return 'Completed'
      when IN_PRINT then return 'In Print'
      when DISPATCHED then return 'Dispatched'
      else return ''
    end
  end

  def self.count_leaflets
    sum(:total_quantity)
  end

  def page
    @page ||= option ? option.page_for_period(period_id) : nil
  end

  def total_nep_boxes
    total_boxes_shipped_via Distribution::SHIP_VIA_NEP
  end

  def total_gh_boxes
    total_boxes_shipped_via Distribution::SHIP_VIA_GH
  end

  def total_pf_boxes
    total_boxes_shipped_via Distribution::SHIP_VIA_PF
  end

  def total_boxes
    total_nep_boxes+total_gh_boxes
  end

  def page
    @page ||= option ? option.page_for_period(period_id) : nil
  end
 
  def calculate_box_count
    box_count.try(:ceil)
  end

  def having_part_box?
    total_box_count = box_count
    return false if total_box_count.nil?
    total_box_count.to_i != total_box_count
  end

  private

  def box_count
    page && page.box_quantity ? (total_quantity.to_f / page.box_quantity.to_f) : nil
  end

  def total_boxes_shipped_via(ship_via)
    (distributions.select {|d| d.ship_via == ship_via}.map {|d| d.calculate_box_count(page) }.reduce :+) || 0
  end

  def option_belongs_to_client
    if option && store && store.client != option.client
      errors.add(:option, 'is not valid for the selected store')
      return false
    end
    true
  end

  def period_belongs_to_client
    if period && store && store.client != period.client
      errors.add(:period, "is not valid for the selected store")
      return false
    end
    true
  end
end
