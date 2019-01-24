# frozen_string_literal: true
class ApplicationMailer < ActionMailer::Base
  default from: ENV['MAILUSER']
  layout 'mailer'
end
