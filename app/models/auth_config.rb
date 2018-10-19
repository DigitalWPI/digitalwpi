class AuthConfig
  # In production, we use Shibboleth for user authentication,
  # but in development mode, you may want to use local database
  # authentication instead.
  def self.use_database_auth?
    !Rails.env.production? && ENV['DATABASE_AUTH'] == 'true'
  end
end
 #gem 'factory_bot_rails' # Needed so we can load fixtures for demos in production