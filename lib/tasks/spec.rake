unless ENV['RAILS_ENV'] == "production"
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
  task :spec => %w[db:test:prepare]
end
