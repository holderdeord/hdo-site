namespace :cache do
  namespace :precompute do
    task :issues => :environment do
      puts "precomputing stats cache for issues"
      Issue.all.each do |e|
        puts e.slug
        e.stats
      end
    end
  end

  task :precompute => %w[cache:precompute:issues]
end