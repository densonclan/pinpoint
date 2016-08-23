class Store < ActiveRecord::Base
  has_paper_trail

  before_validation :set_default_preferred_distribution, :generate_default_account_number, :set_default_reference_number, :clean_logo, :check_preferred_option, :set_values_from_address!

  belongs_to :client
  belongs_to :business_manager, autosave: true
  belongs_to :user
  belongs_to :updated_by, :class_name => "User"
  belongs_to :preferred_option, class_name: 'Option'

  has_many :tasks
  has_many :orders, :dependent => :destroy
  has_many :documents, :dependent => :destroy
  has_many :comments, :as => :commentable, :dependent => :destroy, autosave: true

  belongs_to :address

  extend AccessibleBy
  include Lockable
  include LockChecks

  scope :for_client, lambda { |client| where(client_id: client) unless client.blank? }
  scope :for_business_manager, lambda { |manager| where(business_manager_id: manager) unless manager.blank? }
  scope :for_county, lambda { |county| joins(:address).where("addresses.county IN (?)", county) unless county.blank? }
  scope :updated_by, lambda {|user_id| where('updated_by_id = ?', user_id) unless user_id.blank? }
  scope :updated_before, lambda {|date| where('updated_at < ?', date) unless date.blank? }
  scope :updated_after, lambda {|date| where('updated_at > ?', date) unless date.blank? }
  scope :with_clients, includes(:client)
  scope :for_listing, includes(:business_manager, :client, :orders)
  scope :for_activity_list, includes(:client, :updated_by, :versions)
  scope :ordered, order(:account_number)
  scope :reverse_update_order, order('updated_at DESC')
  scope :matching, lambda {|s| select(:account_number).where('account_number ILIKE ?', "%#{s}%")}
  scope :matching_account_number, lambda {|account_number| where('account_number ILIKE ?', "%#{account_number}%") unless account_number.blank? }
  scope :participating, lambda { where(participation_only: true) }
  scope :nologo, lambda { where("logo='' OR logo IS NULL") }
  scope :noorders, lambda { where ('id NOT IN (SELECT store_id FROM orders)') }
  scope :having_personalised_panel, lambda { where('personalised_panel_1 = ? or personalised_panel_2 = ? or personalised_panel_3 = ?', true, true, true) }
  scope :having_generic_panel, lambda { where('personalised_panel_1 = ? or personalised_panel_2 = ? or personalised_panel_3 = ?', false, false, false) }

  scope :order_by, lambda {|column,direction| 
    column ||= 'account_number'
    direction ||= 'asc'
    order("#{column} #{direction}")
  }

  validates_uniqueness_of :account_number
  validates_format_of :account_number, with: /^[A-Z0-9]+$/, message: 'must contain only letters and numbers'
  validates :preferred_distribution, inclusion: { in: ['Solus', 'Store Delivery', 'Newspaper', 'Royal Mail'] }
  validates :reference_number, :presence => true, :length => { :maximum => 32 }
  validates_presence_of :client_id

  accepts_nested_attributes_for :address, reject_if: lambda { |a| a[:full_name].blank? }
  attr_accessible :address_attributes, :business_manager_id, :client_id, :account_number, :description, :owner_name, :postcode, :preferred_distribution, :reference_number, :logo, :store_urgent, :participation_only, :preferred_option_id, :personalised_address_panel, :personalised_panel_1, :personalised_panel_2, :personalised_panel_3

  scope :list_for, lambda {|user| accessible_by(user).for_listing }

  def self.reset_personalised_panel
    Store.update_all(personalised_panel_1: false, personalised_panel_2: false, personalised_panel_3: false)
  end

  def self.new_with_user(attributes, user)
    store = Store.new
    store.set_attributes_with_user attributes, user
    store.user = user
    store
  end

  def set_attributes_with_user(attributes, user)
    self.attributes = attributes
    self.updated_by = user
    self.client_id = user.client_id unless user.internal?
  end

  def self.search(q)
    joins('LEFT OUTER JOIN business_managers b ON stores.business_manager_id=b.id').\
    where('stores.account_number ILIKE ? OR stores.reference_number ILIKE ? OR stores.description ILIKE ? OR stores.owner_name ILIKE ? OR b.name ILIKE ? OR stores.postcode ILIKE ? OR stores.logo ILIKE ? ', "%#{q}%", "%#{q}%", "%#{q}%", "%#{q}%","%#{q}%", "%#{q}%", "%#{q}%")
  end

  def self.with_most_orders
    joins(:orders).select("stores.id, stores.account_number, COUNT(*) AS order_count").group("stores.id, stores.account_number").order('order_count DESC').first
  end

  def self.without_orders_in_periods(period1, period2)
    if !period2 || period2.new_record?
      where('id NOT IN (SELECT store_id FROM orders WHERE period_id=?)', period1.id)
    else
      where('id NOT IN (SELECT store_id FROM orders WHERE period_id=? OR period_id=?)', period1.id, period2.id)
    end
  end

  def find_others
    Store.where('client_id=? AND owner_name=? AND id<>?', client_id, owner_name, id)
  end

  def self.filter(store_client = nil, store_business_manager = nil, store_county = nil)
    self.for_client(store_client).for_business_manager(store_business_manager).for_county(store_county)
  end

  def store_address
    address
  end

  #
  # If an account number has been left blank, generate a new one, based on the last one created
  #
  def generate_account_number
      last_store = Store.order('account_number DESC').where(' client_id = ?', self.client_id).max

      if last_store
        store_no = last_store.account_number
      else
        store_no = '0'
      end

      # Extract a number
      reggae = /\d+/
      results = reggae.match(store_no)

      # Get difference length
      difference = (results.offset(0).last - results.offset(0).first)

      # Add 1 to the number, and add leading zeros
      result_number = (results[0].to_i) + 1
      new_store_account = "%0#{difference}d" % result_number

      # Add Prefix (PR, A, W, X)
      prefix_string = store_no.slice( 0, results.offset(0).first )

      # Join String
      new_string = "#{prefix_string}#{new_store_account}"

      # Append to store
      new_string
  end

  def set_values_from_address!
    if address
      self.owner_name = address.full_name
      self.postcode = address.postcode
    end
  end

  def client
    super || Client::NullClient.new
  end

  private

  def set_default_preferred_distribution
    self.preferred_distribution = 'Store Delivery' if preferred_distribution.blank?
  end

  def generate_default_account_number
    self.account_number = generate_account_number if account_number.blank?
  end

  def set_default_reference_number   
    self.reference_number = account_number if reference_number.blank?
  end

  def clean_logo
    self.logo = logo[0..-5] if logo.downcase.ends_with?('.bmp') if logo
  end

  def check_preferred_option
    errors.add(:preferred_option, 'is not valid') if preferred_option && preferred_option.client_id != client_id
  end



end