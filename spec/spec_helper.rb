require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

end

Spork.each_run do
  # This code will be run each time you run your specs.

end

# --- Instructions ---
# Sort the contents of this file into a Spork.prefork and a Spork.each_run
# block.
#
# The Spork.prefork block is run only once when the spork server is started.
# You typically want to place most of your (slow) initializer code in here, in
# particular, require'ing any 3rd-party gems that you don't normally modify
# during development.
#
# The Spork.each_run block is run each time you run your specs.  In case you
# need to load files that tend to change during development, require them here.
# With Rails, your application modules are loaded automatically, so sometimes
# this block can remain empty.
#
# Note: You can modify files loaded *from* the Spork.each_run block without
# restarting the spork server.  However, this file itself will not be reloaded,
# so if you change any of the code inside the each_run block, you still need to
# restart the server.  In general, if you have non-trivial code in this file,
# it's advisable to move it into a separate file so you can easily edit it
# without restarting spork.  (For example, with RSpec, you could move
# non-trivial code into a file spec/support/my_helper.rb, making sure that the
# spec/support/* files are require'd from inside the each_run block.)
#
# Any code that is left outside the two blocks will be run during preforking
# *and* during each_run -- that's probably not what you want.
#
# These instructions should self-destruct in 10 seconds.  If they don't, feel
# free to delete them.

Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'

  require 'simplecov'
  SimpleCov.start 'rails'

  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'rspec/autorun'
  require 'database_cleaner'

  require 'hdo/import'

  if ENV['TRAVIS']
    ENV['DISPLAY'] = ":99"
  end

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

  RSpec.configure do |config|
    config.color = $stdout.tty?
    config.order = :random
    config.drb   = true

    config.fixture_path = "#{::Rails.root}/spec/fixtures"
    config.use_transactional_fixtures = false
    config.infer_base_class_for_anonymous_controllers = false
    config.treat_symbols_as_metadata_keys_with_true_values = true

    config.include Devise::TestHelpers, type: :controller
    config.include BrowserSpecHelper, type: :request

    config.before :suite do
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.clean_with :truncation
    end

    config.before :each do
      DatabaseCleaner.start
    end

    config.after :each do
      Rails.cache.clear
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

    if ENV['FOCUS'] or ENV['focus']
      config.filter_run_including :focus => true
    end
  end
end

Spork.each_run do
   # This code will be run each time you run your specs.
end
