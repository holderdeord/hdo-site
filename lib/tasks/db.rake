namespace :db do
  namespace :clear do

    desc 'Remove all votes.'
    task :votes => :environment do
      Vote.destroy_all
    end
    
    desc 'Remove all representatives'
    task :representatives => :environment do
      Representative.destroy_all
    end
  end
end