class PageCount < ReportCount

  attr_accessor :page

  def initialize(page)
    super()
    self.page = page
  end
end