class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("POSTMARK_FROM_EMAIL", "noreply@travelskit.com")
  layout "mailer"
end
