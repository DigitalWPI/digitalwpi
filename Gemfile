source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.5'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.6'
# Use sqlite3 as the database for Active Record
gem "sqlite3", "~> 1.3.0"
# Use Puma as the app server
gem 'puma', '~> 3.11'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# add mysql for prod envs
gem 'mysql2', '< 0.5'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'

gem 'blacklight_oai_provider' # add Blacklight oai for Primo
# gem 'blacklight_oai_provider', '~> 6.1'
gem 'geckodriver-helper', '0.24.0'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'
#
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# gem 'active_attr'
gem 'hyrax', '3.3.0'
gem 'rsolr', '>= 1.0', '< 3'
gem 'bootstrap-sass', '~> 3.0'
gem 'twitter-typeahead-rails', '0.11.1.pre.corejavascript'
gem 'jquery-rails'
gem 'devise'
gem 'devise-guests', '~> 0.6'
gem 'devise-multi_auth', git: 'https://github.com/DigitalWPI/devise-multi_auth', branch: 'rails-5-1'
gem 'hydra-role-management'
gem 'omniauth'
gem 'omniauth-saml'
gem 'orcid', git: 'https://github.com/uclibs/orcid', branch: 'rails-5.x'

gem 'sidekiq', '~> 6.0'

gem 'bootstrap-datepicker-rails'
gem 'pg'

gem 'riiif', '~> 2.3'
gem 'coveralls', require: false
gem 'solrizer', '~> 4.1'

gem 'active_fedora-noid'

# for pdfviewer
gem 'pdfjs_viewer-rails', git: 'https://github.com/TuftsUniversity/pdfjs_viewer-rails.git', tag: 'tdl-20200428'

gem 'honeypot-captcha'
gem 'lograge'
gem 'logstash-event'
gem 'honeybadger', '~> 4.0'
gem 'rack-attack'
gem 'xray-rails'
gem 'yajl-ruby', require: 'yajl'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Bulkrax Importer
gem 'bulkrax', '~> 5.2'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'capybara', '>= 2.15'
  gem 'factory_bot_rails'
  gem 'launchy'
  # gem 'rspec-activemodel-mocks'
  # gem 'rspec-its'
  gem 'rspec-rails'
  # gem 'shoulda-matchers'
  gem 'solr_wrapper', '>= 0.3'
  gem 'fcrepo_wrapper'
  gem 'rspec_junit_formatter'
  gem 'database_cleaner'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  # Adds support for system testing using selenium driver
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'chromedriver-helper'
  gem 'faker' # #comment from besss: Needed so we can load fixtures for demos in production
  gem 'ffaker'
end

group :deployment, :development do
  gem "capistrano", "~> 3.11", require: false
  gem "capistrano-rails", "~> 1.3", require: false
end

gem "blacklight_advanced_search"
gem "blacklight_range_limit"

