# -*- coding: utf-8 -*-
namespace :twitter do
  desc "Tweet the last day's rebel votes"
  task :rebels => :environment do
    Hdo::Utils::RebelTweeter.since(1.day.ago).tweet
  end

  namespace :representatives do
    desc 'Make sure @holderdeord follows all representative Twitter accounts'
    task :follow => :environment do
      client = Hdo::Utils::TwitterClients.hdo
      followed = client.follow(*Representative.with_twitter.map(&:twitter_id))

      if followed.any?
        puts "followed new users: "
        followed.each { |e| puts "  --> #{e.screen_name}" }
      end
    end

    desc "Check if Stortinget's representative list has any Twitter handles we're missing"
    task :check => :environment do
      screen_names = Hdo::Utils::TwitterClients.hdo.
                       list_members("Stortinget", 'representanter').map { |e| e.screen_name.downcase }
      missing = screen_names - Representative.with_twitter.pluck(:twitter_id).map(&:downcase)

      if missing.any?
        puts "Not found in HDO's DB:"
        puts missing
      else
        puts "No missing representatives found."
      end
    end

    desc "Add all DB reps to our public 'Politikere på Twitter' list"
    task :sync => :environment do
      client = Hdo::Utils::TwitterClients.hdo
      Representative.with_twitter.pluck(:twitter_id).each_slice(50) do |slice|
        puts slice.size
        client.add_list_members('holderdeord', 'politikere-på-twitter', slice)
      end
    end

    desc "Print representatives who are not on Twitter"
    task :missing => :environment do
      reps = Representative.without_twitter

      if ENV['CSV'] || ENV['csv']
        require 'csv'

        STDOUT << CSV.generate(col_sep: "\t") do |csv|
          csv << ['status', 'slug', 'name', 'party', 'twitter_id']

          reps.each do |r|
            csv << [
              r.attending? ? 'møtende' : '',
              r.slug,
              r.name,
              r.latest_party.name,
              r.twitter_id
            ]
          end
        end
      else
        reps.each do |r|
          puts "#{r.slug}: #{r.full_name} #{r.latest_party.external_id}"
        end
      end

    end

  end
end
