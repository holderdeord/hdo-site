# encoding: utf-8

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

    desc 'Remove all promises'
    task :promises => :environment do
      Promise.destroy_all
    end

    desc 'Remove all issues'
    task :issues => :environment do
      Issue.destroy_all
    end
  end

  namespace :valence do
    task :convert => :environment do
      Issue.where(valence_issue: false).each do |issue|
        p issue.to_param

        parties   = issue.votes.flat_map { |e| e.stats.parties }.uniq
        positions = Hash.new { |hash, title| hash[title] = [] }
        stats     = issue.stats

        parties.each do |party|
          positions[stats.key_for(stats.score_for(party))] << party
        end

        issue.last_updated_by_id = 1
        issue.valence_issue = true

        positions.each do |position, parties|
          title, pri = case position
                       when :for
                         ["Stemt for", 1]
                       when :for_and_against
                         ["Stemt både for og mot", 2]
                       when :against
                         ["Stemt mot", 3]
                       when :not_participated
                         ["Ikke deltatt i nok avstemninger", 4]
                       else
                         raise "unknown position: #{position.inspect}"
                       end

          issue.valence_issue_explanations.create!(parties: parties, title: title)
        end

        issue.promise_connections.each do |pc|
          next if pc.related?

          promise_parties = pc.promise.parties
          party_scores = promise_parties.map { |party| stats.score_for(party) }.compact

          if party_scores.nil?
            pc.status = 'related'
          else
            vote_score = party_scores.sum / promise_parties.size

            if pc.for?
              pc.override = vote_score
            elsif pc.against?
              pc.override = (100 - vote_score)
            end
          end

          pc.save!
        end

        issue.save!
      end
    end
  end
end
