namespace :cache do
  namespace :precompute do
    task :issues => :environment do
      puts "precomputing stats cache for issues"
      Issue.published.each do |e|
        e.stats
        e.accountability
        puts e.slug
      end
    end
  end

  task :precompute => %w[cache:precompute:issues]
end