class PeriodDecorator < Draper::Decorator

  delegate :client, :period_number, :year, :orders

  def to_s
    "##{period_number} #{year}#{object.current ? ' - Current' : nil}"
  end

  def id
    object.id
  end

  def name
    (context[:user].internal? ? "#{client.name} ##{period_number} #{year}" : "Period ##{period_number} #{year}") + (object.current? ? ' - Current' : '')
 
  end

  def dispatch_date
    object.date_dispatch ? object.date_dispatch.strftime('%d %B %Y') : '-'
  end
end