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
        require 'nokogiri'

        threshold = Float(ENV['COVERAGE_THRESHOLD'] || ENV['THRESHOLD'] || 60)
        path = Rails.root.join("coverage/index.html")
        doc = Nokogiri::HTML.parse File.read(path)

        node = doc.css("h2:first .covered_percent").first
        str = node && node.content[/(\d+\.\d+)%/, 1] || raise("unable to parse coverage from #{path}")
        covered = Float(str)

        if covered < threshold
          raise "Test coverage #{covered}% is below the threshold of #{threshold}%. Not good enough, sorry."
        end
      end
    end

  end
end
