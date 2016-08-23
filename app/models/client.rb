class Client < ActiveRecord::Base
  has_paper_trail

  has_many :stores
  has_many :orders, through: :stores
  has_many :business_managers
  has_many :periods
  has_many :users

  validates_presence_of :name
  validates_presence_of :reference, :allow_blank => true
  validates_presence_of :code
  validates_length_of :description, :maximum => 400, :allow_blank => true
  validates_uniqueness_of :name, :code

  attr_accessible :code, :description, :name, :reference

  scope :ordered, order(:name)
  scope :with_periods, includes(:periods)
  scope :accessible_by, lambda {|user| where(user.internal? ? true : {id: user.client_id})}

  def self.lookup(name_or_code)
    where('name=? OR code=?', name_or_code, name_or_code).first
  end

  def period(period_number)
    periods.ordered.select {|period| period.period_number == period_number}.first
  end

  def current_period
    periods.ordered.select {|period| period.current}.first
  end

  def current_orders
    orders.for_period(current_period)
  end
end
