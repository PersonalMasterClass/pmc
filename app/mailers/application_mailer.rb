class ApplicationMailer < ActionMailer::Base
  default from: ENV['MAILER_SENDER'] || "noreply@personalmasterclass.com"
  layout 'mailer'
end
