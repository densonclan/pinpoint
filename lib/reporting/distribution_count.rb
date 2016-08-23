class DistributionCount < ReportCount

  attr_reader :distributor_id

  def initialize(distributor_id)
    super()
    @distributor_id = distributor_id
  end
end