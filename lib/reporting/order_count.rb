class OrderCount < ReportCount

  attr_reader :status, :option_id

  def initialize(status, option_id)
    super()
    @status = status
    @option_id = option_id
    @order_ids = []
  end
end