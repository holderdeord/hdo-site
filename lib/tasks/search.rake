namespace :search do
  task :drop do
    ENV['INDEX'] = "issues,parties,representatives,promises,propositions,parliament_issues,topics"
    Rake::Task['tire:index:drop'].invoke
  end

  task :reindex => :environment do
    [ Issue,
      ParliamentIssue,
      Proposition,
      Promise,
      Representative,
      Party,
      Topic
    ].each do |klass|
      next if ENV['CLASS'] && ENV['CLASS'] != klass.to_s
      puts "\n#{klass}"
      total = klass.count.to_f

      index = klass.index

      index.delete
      index.create :mappings => klass.tire.mapping_to_hash, :settings => klass.tire.settings

      klass.import do |docs|
        puts "\t#{docs.to_a.size}"
        docs # must be returned
      end
    end
  end
end