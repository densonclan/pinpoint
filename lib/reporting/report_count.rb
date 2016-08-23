class ReportCount
  attr_reader :count, :total_quantity, :total_boxes

  def initialize
    @count = 0
    @total_quantity = 0
    @total_boxes = 0
  end

  def add_item(order_or_distribution, page)
    add_to_count
    add_to_total_quantity order_or_distribution.total_quantity
    add_to_total_boxes order_or_distribution, page
  end

  def add_to_count
    @count += 1
  end

  def add_to_total_quantity(quantity)
    @total_quantity += quantity
  end

  def add_to_total_boxes(order_or_distribution, page)
    @total_boxes += calculate_total_boxes(order_or_distribution, page)
  end

  def calculate_total_boxes(order_or_distribution, page)
    return 0 unless page && page.box_quantity > 0
    (order_or_distribution.total_quantity.to_f / page.box_quantity.to_f).ceil
  end
end