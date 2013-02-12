namespace :search do
  desc 'Reindex'
  task :reindex => :environment do
    Hdo::Search::Settings.models.each do |klass|
      next if ENV['CLASS'] && ENV['CLASS'] != klass.to_s
      puts "\n#{klass}"

      total = klass.count
      index = klass.index

      index.delete
      ok = index.create :mappings => klass.tire.mapping_to_hash, :settings => klass.tire.settings
      ok or raise "unable to create #{index.name}, #{index.response && index.response.body}"

      indexed_count = 0

      klass.import { |docs|
        if klass == Issue
          # don't index unpublished issues.
          docs = docs.select { |e| e.published? }
        end

        count = docs.to_a.size
        indexed_count += count
        puts "\t#{count} (#{indexed_count}/#{total})"

        docs
      }
    end
  end

  desc 'Run a fake search server'
  task :fake do
    require 'rack'
    Rack::Server.new(app: lambda { |env| [200, {}, ["{}"]]}, :Port => 9200, :server => "thin").start
  end
end