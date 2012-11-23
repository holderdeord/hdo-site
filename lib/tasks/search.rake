namespace :search do
  desc 'Reindex'
  task :reindex => :environment do
    Hdo::Search::Settings.models.each do |klass|
      next if ENV['CLASS'] && ENV['CLASS'] != klass.to_s
      puts "\n#{klass}"

      total = klass.count.to_f
      index = klass.index

      index.delete
      ok = index.create :mappings => klass.tire.mapping_to_hash, :settings => klass.tire.settings
      ok or raise "unable to create #{index.name}, #{index.response.body}"

      klass.import { |docs|
        if klass == Issue
          # don't index unpublished issues.
          docs = docs.select { |e| e.published? }
        end

        puts "\t#{docs.to_a.size}"

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