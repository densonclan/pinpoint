module PodsHelper

	  def pod_date(date)
    date ? date.strftime('%d %B %Y') : '-'
  end

end
