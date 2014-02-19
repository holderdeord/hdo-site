namespace :cache do
  namespace :precompute do
    task :issues => :environment do
      unless Issue.table_exists?
        puts "database not created - moving on"
        next
      end

      puts "precomputing stats cache for issues"

      periods = [
        ParliamentPeriod.named('2009-2013'),
        ParliamentPeriod.named('2013-2017')
      ]

      Issue.published.each do |i|
        periods.each { |pp| i.accountability(pp) }
        puts i.slug
      end
    end
  end

  task :precompute => %w[cache:precompute:issues]
end