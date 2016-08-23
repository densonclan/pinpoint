class AddressDecorator < Draper::Decorator
  delegate_all

  def to_s
    "#{full_name} - #{first_line}, #{city}, #{postcode}"
  end
end