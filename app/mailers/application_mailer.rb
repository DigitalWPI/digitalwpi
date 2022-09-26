class ApplicationMailer < ActionMailer::Base
  default from: "DigitalWPI Repository <#{ENV['MAILUSER']}>"
  layout 'mailer'
end
