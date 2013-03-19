unless ENV['RAILS_ENV'] == "production"
  namespace :spec do
    desc 'Run small specs (lib, model, controller)'
    task :small => %w[spec:lib spec:models spec:controllers]

    desc 'Run large specs (requests).'
    task :large => %w[spec:requests]

    desc 'Run all specs (including buster).'
    task :all   => %w[spec js:test]

    namespace :coverage do
      desc "Make sure test coverage doesn't drop below THRESHOLD"
      task :ensure do
        require 'json'

        threshold = Float(ENV['COVERAGE_THRESHOLD'] || ENV['THRESHOLD'] || 80)
        path = Rails.root.join("coverage/.last_run.json")
        data = JSON.parse File.read(path)

        covered = data.fetch('result').fetch('covered_percent')

        if covered < threshold
          raise "Test coverage #{covered}% is below the threshold of #{threshold}%. Not good enough, sorry."
        end
      end
    end

  end
end
