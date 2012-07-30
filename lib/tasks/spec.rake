unless ENV['RAILS_ENV'] == "production"
  require 'rspec/core/rake_task'

  namespace :spec do
    RSpec::Core::RakeTask.new(:small) do |t|
      t.pattern = 'spec/{hdo,models,controllers}/**/*_spec.rb'
    end

    RSpec::Core::RakeTask.new(:large) do |t|
      t.pattern = 'spec/large/**/*_spec.rb'
    end

    RSpec::Core::RakeTask.new(:controllers) do |t|
      t.pattern = 'spec/controllers/**/*_spec.rb'
    end

    task :all => %w[spec:small spec:large]
  end

  task :spec => 'spec:small'

  task 'spec:small' => 'db:test:prepare'
  task 'spec:large' => 'db:test:prepare'
  task 'spec:controllers' => 'db:test:prepare'
end
