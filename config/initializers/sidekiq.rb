# frozen_string_literal: true
config = YAML.safe_load(ERB.new(IO.read(Rails.root + 'config' + 'redis.yml')).result)[Rails.env].with_indifferent_access
Sidekiq.logger.level = Logger::WARN if ENV['RAILS_ENV'] == 'production'
Sidekiq.strict_args!(false)

Sidekiq.configure_server do |s|
  s.redis = config
end

Sidekiq.configure_client do |s|
  s.redis = config
end