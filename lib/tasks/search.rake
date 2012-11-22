namespace :search do
  task :drop do
    ENV['INDEX'] = "issues,parties,representatives,promises,propositions,parliament_issues,topics"
    Rake::Task['tire:index:drop'].invoke
  end

  task :reindex => :environment do
    Hdo::Search::Settings.models.each do |klass|
      next if ENV['CLASS'] && ENV['CLASS'] != klass.to_s
      puts "\n#{klass}"

      total = klass.count.to_f
      index = klass.index

      index.delete
      index.create :mappings => klass.tire.mapping_to_hash, :settings => klass.tire.settings

      klass.import { |docs|
        if klass == Issue
          docs = docs.select { |e| e.published? }
        end

        puts "\t#{docs.to_a.size}"

        docs
      }
    end
  end
end