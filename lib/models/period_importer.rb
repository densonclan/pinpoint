class PeriodImporter < Importer

  def model_class
    Period
  end

  def set_extra_attributes(period, row, i)
    set_client(period, row['client'], i)
  end

  def self.field_names
    %w(period_number client week_number date_promo date_samples date_approval date_print date_dispatch current completed date_promo_end)
  end
end