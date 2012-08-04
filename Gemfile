source 'https://rubygems.org'

gem 'rails', '3.2.7'

gem 'nokogiri', '~> 1.5.0'
gem 'acts_as_tree', '~> 0.1.1'
gem 'capistrano', '~> 2.12.0'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'less'
  gem 'uglifier', '>= 1.0.3'
end

group :test do
  gem "selenium-webdriver", "~> 2.0"
  gem "machinist", "~> 2.0"
  gem "database_cleaner", "~> 0.8.0"
  gem "loadable_component", ">= 0.1.1"
  gem 'simplecov', :require => false
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-spork'
  gem 'ruby_gntp'
end

group :test, :development do
  gem "rspec-rails", "~> 2.11"
end

group :development do
  gem 'sqlite3' # TODO: same DB everywhere
  gem "rails-erd"
end

group :production do
  gem 'pg'
end

gem "thin"
gem 'jquery-rails'
gem "twitter-bootstrap-rails", "~> 2.0"
gem "highcharts-rails", "~> 2.2"
gem "jquery-tablesorter", ">= 0.0.5"
gem "devise", "~> 2.1.2"
gem "twitter_bootstrap_form_for", "~> 1.0.5"
gem "will_paginate", "~> 3.0.3"
gem "friendly_id", "~> 4.0.7"
gem 'rack-cache', :require => 'rack/cache'
gem 'dragonfly', '~> 0.9.12'
gem 'lograge'
gem 'unicode_utils'
gem 'pry'

# data import
# gem 'hdo-storting-importer', :path => "../hdo-storting-importer"
gem 'hdo-storting-importer', "~> 0.0.7"

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the web server
# gem 'unicorn'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'
