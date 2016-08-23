class SharedFolderMailer < ActionMailer::Base
  default from: "pinpoint@gaskandhawley.com"

  def notify(shared_folder)
    @shared_folder = shared_folder
    mail to: recipient(shared_folder.user.email), subject: "You have a new folder shared by #{shared_folder.folder.user.name}"
  end

  private

  def recipient(r)
    Rails.env.development? ? ['barry.denson@gaskandhawley.com'] : r
  end
end