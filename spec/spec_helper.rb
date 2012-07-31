ENV["RAILS_ENV"] ||= 'test'

require 'simplecov'
SimpleCov.start 'rails'

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'database_cleaner'

if ENV['TRAVIS']
  ENV['DISPLAY'] = ":99"
end

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.color = $stdout.tty?
  config.order = :random
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.use_transactional_fixtures = false
  config.infer_base_class_for_anonymous_controllers = false

  config.before :suite do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :truncation
  end

  config.before :each do
    DatabaseCleaner.start
  end

  config.after :each do
    DatabaseCleaner.clean
  end

  config.before :each, type: :request do
    DatabaseCleaner.strategy = :truncation
  end

  config.before :all, type: :request do
    DatabaseCleaner.strategy = :truncation
    BrowserSpecHelper.start
  end

  config.after :all, type: :request do
    BrowserSpecHelper.stop
  end
end
