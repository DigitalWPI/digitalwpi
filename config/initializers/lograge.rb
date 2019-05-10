Rails.application.configure do
  config.lograge.base_controller_class = 'ActionController::Base'
  config.lograge.enabled = true
  config.lograge.formatter = Lograge::Formatters::Logstash.new
  config.lograge.keep_original_rails_log = true
  config.lograge.logger = ActiveSupport::Logger.new "#{Rails.root}/log/lograge_#{Rails.env}.log"
  config.lograge.custom_options = lambda do |event|
    {
      time: Time.now,
      remote_ip: event.payload[:remote_ip],
      params: event.payload[:params],
      user_id: event.payload[:user_id],
      referer: event.payload[:referer]
    }
  end
end
