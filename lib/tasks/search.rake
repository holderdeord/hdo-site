namespace :search do
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

      klass.index.delete
      klass.import do |docs|
        puts "\t#{docs.to_a.size}"
        docs # must be returned
      end
    end
  end
end