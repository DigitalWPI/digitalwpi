require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DigitalWpi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2
    config.active_job.queue_adapter = ENV.fetch('HYRAX_ACTIVE_JOB_QUEUE') { 'async' }.to_sym

    config.add_autoload_paths_to_load_path = true

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.middleware.use Rack::Attack
    #config.eager_load_paths << Rails.root.join('lib')
    #config.time_zone = "Eastern Time (US & Canada)"
    # Sometimes, just setting above config doesn't work.
    # Set following as well
    #config.active_record.default_timezone = :utc
  end
end