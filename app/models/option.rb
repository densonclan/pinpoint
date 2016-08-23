class Option < ActiveRecord::Base
  has_paper_trail

  has_many :orders
  has_many :values, class_name: 'OptionValue', autosave: true
  has_many :pages, through: :values
  belongs_to :client

  extend AccessibleBy


  before_validation :calculate_totals
  before_validation :build_values, on: :create
  validates_presence_of :name, :client, :price_zone
  validates_length_of :description, maximum: 255, allow_blank: true
  validates_length_of :reference_number, maximum: 255, allow_blank: true

  attr_accessible :description, :name, :reference_number, :client_id, :values_attributes, :licenced, :multibuy, :price_zone, :total_ambient, :total_licenced, :total_temp
  accepts_nested_attributes_for :values

  scope :for_listing, includes(:client)
  scope :ordered, order(:client_id, :name)
  scope :reverse_ordered, order('client_id, name DESC')
  scope :for_client, lambda{|id| where(client_id: id)}
  scope :with_all_values, includes(:values => :period)
  scope :named, lambda{|name| where('name=? OR reference_number=?', name, name)}

  def self.names_for_client(client_id)
    for_client(client_id).select(:name).order(:name).map{|p| p.name}
  end

  def self.as_hash
    options = {}
    all.each {|o| options[o.id] = o}
    options
  end

  def current_value
    values.select {|v| v.current? }.first || values.build(period: client.current_period)
  end

  def page
    @page ||= current_value.page
  end

  def page_for_period(period_id)
    value = values.select {|v| v.period_id == period_id.to_i}.first
    value ? value.page : nil
  end

  private
  def calculate_totals
    self.total_quantity = self.total_ambient + self.total_licenced + self.total_temp
  end

  def build_values
    if client
      client.periods.each do |period|
        self.values.build period_id: period.id
      end
    end
  end
end