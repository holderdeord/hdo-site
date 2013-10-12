namespace :cache do
  namespace :precompute do
    task :issues => :environment do
      unless Issue.table_exists?
        puts "database not created - moving on"
        next
      end

      puts "precomputing stats cache for issues"

      Issue.published.each do |e|
        e.accountability
        puts e.slug
      end
    end
  end

  task :precompute => %w[cache:precompute:issues]
end