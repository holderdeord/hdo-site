source 'https://rubygems.org'

def darwin_only(require_as)
  RUBY_PLATFORM.include?('darwin') && require_as
end

def linux_only(require_as)
  RUBY_PLATFORM.include?('linux') && require_as
end

gem 'rails', '3.2.15'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'less-rails'
  gem 'sass-rails', '~> 3.2.3'

  gem 'therubyracer', platform: :ruby
  gem 'uglifier', '>= 1.0.3'
end

group :test do
  gem "selenium-webdriver", "~> 2.35.1"
  gem "machinist", "~> 2.0"
  gem "database_cleaner", "~> 0.9.1"
  gem "loadable_component", ">= 0.1.1"
  gem 'simplecov', require: false
  gem 'fuubar'
  gem 'coveralls', require: false

  # guard
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-spin'
  gem 'rb-fsevent', require: darwin_only('rb-fsevent')
  gem 'rb-inotify', require: linux_only('rb-inotify')
end

group :test, :development do
  gem "rspec-rails", "~> 2.13"
  gem 'jasmine'
end

group :development do
  gem 'thin'
  gem "rails-erd"
  gem 'quiet_assets'
  gem 'bullet'
  gem 'meta_request'
end

# deployment
gem 'capistrano', '~> 2.13'
gem 'capistrano-maintenance'
gem 'capistrano-ext'
gem 'hipchat'

# frontend stuff
gem 'jquery-rails', '>= 3.0.4'
gem 'highcharts-rails', "~> 2.2"
gem 'jquery-tablesorter', ">= 1.5.0"
gem 'redcarpet'

# authentication
gem 'devise', "~> 2.2.5"

# authorization
gem 'pundit'

# pagination
gem 'will_paginate', "~> 3.0.3"

# url slugs
gem 'friendly_id', "~> 4.0"

# view models
gem 'draper'

# various db / model
gem 'pg'
gem 'acts_as_tree', '~> 1.1'
gem 'yaml_db' # db dump / load
gem 'acts-as-taggable-on', '~> 2.4.1'

# search
gem 'tire'

# caching
gem 'cache_digests'

# images
gem 'mini_magick', "~> 3.5"
gem 'carrierwave', '~> 0.8'

# logging
gem 'lograge'

# email
gem 'mail'
gem 'valid_email'

# serialization / parsing
gem 'multi_json'
gem 'yajl-ruby'
gem 'nokogiri'
gem 'unicode_utils'

# debugging
gem 'pry'

# app settings
gem 'settingslogic'

# instrumentation
gem 'statsd-ruby', :require => 'statsd'
gem 'newrelic_rpm'

# http
gem 'faraday'
gem 'typhoeus'
gem 'net-http-persistent'

# cors
gem 'rack-cors', :require => 'rack/cors'

# state machine
gem 'workflow'

# data import
if ENV['LOCAL_IMPORTER']
  gem 'hdo-storting-importer', :path => File.expand_path("../../hdo-storting-importer", __FILE__)
else
  gem 'hdo-storting-importer', "~> 0.5.2", require: 'hdo/storting_importer'
end

