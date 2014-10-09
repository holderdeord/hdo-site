namespace :twitter do
  desc "Tweet the last day's rebel votes"
  task :rebels => :environment do
    Hdo::Utils::RebelTweeter.since(1.day.ago).tweet
  end
end
