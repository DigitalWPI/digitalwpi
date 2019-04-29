# frozen_string_literal: true
source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end
group :production, :development, :test do
  # Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
  gem 'rails', '~> 5.1.6.1'
  # Use sqlite3 as the database for Active Record
  gem 'sqlite3', '~> 1.3.13'
  # Use Puma as the app server
  gem 'puma', '~> 3.7'
  # Use SCSS for stylesheets
  gem 'sass-rails', '~> 5.0'
  # Use Uglifier as compressor for JavaScript assets
  gem 'uglifier', '>= 1.3.0'
  # See https://github.com/rails/execjs#readme for more supported runtimes
  # gem 'therubyracer', platforms: :ruby

  # Use CoffeeScript for .coffee assets and views
  gem 'coffee-rails', '~> 4.2'
  # Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
  gem 'turbolinks', '~> 5'
  # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
  gem 'jbuilder', '~> 2.5'
  # add mysql for prod envs
  gem 'mysql2', '< 0.5'
  # Use Redis adapter to run Action Cable in production
  # gem 'redis', '~> 4.0'
  # Use ActiveModel has_secure_password
  # gem 'bcrypt', '~> 3.1.7'

  # Use Capistrano for deployment
  # gem 'capistrano-rails', group: :development
  gem 'autometal-piwik', '>= 1.0'
  gem 'factory_bot_rails' # #comment from besss: Needed so we can load fixtures for demos in production
  gem 'faker' # #comment from besss: Needed so we can load fixtures for demos in production
  gem 'ffaker'

  gem 'active_attr'
  gem 'active_fedora-noid'
  gem "bootstrap-sass", ">= 3.4.1"
  gem "devise", ">= 4.6.0"
  gem 'devise-guests', '~> 0.6'
  gem 'devise-multi_auth', git: 'https://github.com/DigitalWPI/devise-multi_auth', branch: 'rails-5-1'
  gem 'hydra-role-management'
  gem 'hyrax', git: 'https://github.com/samvera/hyrax.git', tag: 'v2.5.0'
  gem 'jquery-rails'
  gem 'lograge'
  gem 'omniauth'
  gem 'omniauth-saml'
  gem 'orcid', git: 'https://github.com/uclibs/orcid', branch: 'rails-5-1-6'
  gem 'honeybadger', '~> 4.0'
  gem 'rack-attack'
  gem 'riiif', '~> 2.0'
  gem 'rsolr', '>= 1.0'
  gem 'sidekiq'
  gem 'xray-rails'
end

group :development, :test do
  gem 'bixby'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 2.13'
  gem 'database_cleaner'
  gem 'fcrepo_wrapper'
  gem 'launchy'
  gem 'rspec-activemodel-mocks'
  gem 'rspec-its'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'solr_wrapper', '>= 0.3'
  gem 'rspec_junit_formatter'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :deployment, :development do
  gem "capistrano", "~> 3.11", require: false
  gem "capistrano-rails", "~> 1.3", require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
