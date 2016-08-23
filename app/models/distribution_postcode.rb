class DistributionPostcode < ActiveRecord::Base

  belongs_to :distribution
  belongs_to :postcode_sector
end