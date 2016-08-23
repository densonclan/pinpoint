class UserMailer < ActionMailer::Base
  default from: "pinpoint@gaskandhawley.com"

  def require_activation_email(user)
    @user = user
    to = recipient(admins)
    mail to: to, subject: "A new Pinpoint user requires activation" unless to.empty?
  end

  def user_activated_email(user)
    @user = user
    mail to: recipient(user.email), subject: 'Your Pinpoint account has been activated'
  end

  private

  def admins
    Rails.configuration.notifications["UserMailer"]["require_activation_email"]
  end

  def recipient(r)
    Rails.env.development? ? ['barry.denson@gaskandhawley.com'] : r
  end
end