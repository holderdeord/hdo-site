unless ENV['RAILS_ENV'] == "production"
  require 'rspec/core/rake_task'

  namespace :spec do
    RSpec::Core::RakeTask.new(:small) do |t|
      t.pattern = 'spec/{hdo,models}/**/*_spec.rb'
    end

    RSpec::Core::RakeTask.new(:large) do |t|
      t.pattern = 'spec/large/**/*_spec.rb'
    end
  end

  task :spec => %w[db:test:prepare small]
end
