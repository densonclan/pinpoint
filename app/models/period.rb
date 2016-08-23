class Period < ActiveRecord::Base
  has_paper_trail
  after_create :create_default_option_values

  self.primary_key = 'id'

  belongs_to :client
  has_many :orders, :dependent => :destroy

  before_validation :set_current_to_false_if_null
  validates :week_number, :numericality => { :greater_than => 0 }
  validates_numericality_of :year, greater_than: 2012
  validates_inclusion_of :current, in: [true, false]
  validates_presence_of :date_promo, :date_dispatch, :client, :year
  validates_uniqueness_of :period_number, scope: [:client_id, :year]
  validates :period_number, format: { without: /\A[^0-9]+\z|\..*\./, message: 'should contain number and 1 point or none' }

  before_create :set_id

  extend AccessibleBy

  scope :list_for, lambda {|user| accessible_by(user).for_listing }
  scope :all_current, where("current = ?", true)
  scope :completed, where('completed = ?', true)
  scope :for_client, lambda { |id| where(client_id: id) }
  scope :with_client, includes(:client)
  scope :ordered_among_all, -> { order("#{db_string_to_float(:period_number)}") }
  scope :ordered, -> { order("client_id, year, #{db_string_to_float(:period_number)}") }
  scope :ordered_for_form_selection, -> { order("current ASC, client_id, year, #{db_string_to_float(:period_number)}") }
  scope :ordered_for_export, -> { order("current DESC, client_id, year, #{db_string_to_float(:period_number)}") }
  # default_scope, -> { order("client_id, year, #{db_string_to_float(:period_number)}") }

  attr_accessible :date_approval, :date_dispatch, :date_print, :date_promo, :date_promo_end, :date_samples, :period_number, :week_number, :current, :completed, :client_id, :year

  def previous_period
    same_year_previous_period || previos_year_last_period
  end

  def next_period
    @next_period ||= same_year_next_period || next_year_first_period
  end

  def client
    super || Client::NullClient.new
  end

  private

  def self.db_string_to_float(str)
    "regexp_replace(#{str}, '[^0-9.]+', '', 'g')::float"
  end

  def db_string_to_float(*args)
    self.class.db_string_to_float(*args)
  end

  def same_year_previous_period
    Period.for_client(client_id).where(year: year)
      .where("#{db_string_to_float(:period_number)} < #{db_string_to_float('?')}", period_number.to_s).order("#{db_string_to_float(:period_number)} DESC").first
  end

  def same_year_next_period
    Period.for_client(client_id).where(year: year)
      .where("#{db_string_to_float(:period_number)} > #{db_string_to_float('?')}", period_number.to_s).order("#{db_string_to_float(:period_number)} ASC").first
  end

  def previos_year_last_period
    Period.for_client(client_id).where(year: year - 1).order("#{db_string_to_float(:period_number)} DESC").first
  end

  def next_year_first_period
    Period.for_client(client_id).where(year: year + 1).order("#{db_string_to_float(:period_number)} ASC").first
  end

  def create_default_option_values
    previous = previous_period
    if previous
      OptionValue.joins(:option).where('client_id=? AND period_id=?', client_id, previous.id).each do |v|
        OptionValue.create option: v.option, period_id: id, page_id: v.page_id
      end
    end
  end

  def set_id
    self.id = ActiveRecord::Base.connection.execute("SELECT nextval('periods_id_seq')")[0]["nextval"] if self.id.nil?
  end

  def set_current_to_false_if_null
    self.current = false unless current
    true
  end
end
