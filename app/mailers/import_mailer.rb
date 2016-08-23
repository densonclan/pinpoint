class ImportMailer < ActionMailer::Base
  default from: "pinpoint@gaskandhawley.com"

  def complete(importer)
    @errors = importer.errors
    @success_count = importer.success_count
    @name = importer.name.downcase
    mail to: importer.user.email, subject: "PinPoint #{@name} import complete"
  end

  def errored(importer, exception)
    @exception = exception
    mail to: importer.user.email, bcc: "pinpoint@gaskandhawley.com", subject: "An error occurred with your import"
  end

  def invalid(importer)
    @valid_headers = importer.class.field_names
    @invalid_headers = importer.invalid_headers
    mail to: importer.user.email, bcc: "pinpoint@gaskandhawley.com", subject: "Invalid Pinpoint import"
  end
end