ENV["RAILS_ENV"] ||= 'test'

require 'coveralls'
Coveralls.wear!

require 'simplecov'
SimpleCov.start 'rails'

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'database_cleaner'
require 'pry'

require 'hdo/import'

if ENV['TRAVIS']
  ENV['DISPLAY'] = ":99"
end

# ensure correct require order
require Rails.root.join('spec/support/pages/waitable')
require Rails.root.join('spec/support/pages/page')
require Rails.root.join('spec/support/pages/menu')

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.color     = $stdout.tty?
  config.order     = :random
  config.drb       = true

  config.add_formatter Fuubar

  config.profile_examples = true

  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = false
  config.infer_base_class_for_anonymous_controllers = false
  config.treat_symbols_as_metadata_keys_with_true_values = true

  config.include Devise::TestHelpers, type: :controller
  config.include BrowserSpecHelper, type: :request
  config.include CacheSpecHelper, :cache
  config.include SearchSpecHelper, :search

  config.before :suite do
    DatabaseCleaner.strategy = :deletion
    DatabaseCleaner.clean_with :truncation

    SearchSettings.models.each { |m| m.__elasticsearch__.create_index! force: true }
  end

  config.after :suite do
    SearchSettings.models.each { |m| m.__elasticsearch__.delete_index! force: true }
  end

  config.before :each do
    DatabaseCleaner.start
  end

  config.after :each do
    Rails.cache.clear
    DatabaseCleaner.clean
  end

  config.before :all, type: :request do
    BrowserSpecHelper.start
  end

  config.after :all, type: :request do
    BrowserSpecHelper.stop
  end

  config.before :each, :search do
    recreate_index
    refresh_index
  end

  config.around :each, :cache do |example|
    CacheSpecHelper.with_caching(example)
  end

  if ENV['FOCUS'] or ENV['focus']
    config.filter_run_including :focus => true
  end
end

