class OptionValue < ActiveRecord::Base
  belongs_to :option
  belongs_to :period
  belongs_to :page

  attr_accessible :page_id, :period_id, :option, :period

  scope :with_periods, includes(:period)
  scope :ordered, joins(:period).order('periods.year, periods.period_number')

  def current?
    period && period.current?
  end
end