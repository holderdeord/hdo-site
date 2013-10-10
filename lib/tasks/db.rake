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
          update = case position
                   when :for
                     {title: "Stemt for", priority: 0}
                   when :for_and_against
                     {title: "Stemt både for og mot", priority: 1}
                   when :against
                     {title: "Stemt mot", priority: 2}
                   when :not_participated
                     {title: "Ikke deltatt i nok avstemninger", priority: 3}
                   else
                     raise "unknown position: #{position.inspect}"
                   end

          issue.valence_issue_explanations.create!(update.merge(parties: parties))
        end

        issue.promise_connections.each do |pc|
          next if pc.related?

          promise_parties = pc.promise.parties
          party_scores = promise_parties.map { |party| stats.score_for(party) }.compact

          if party_scores.empty?
            pc.status = 'related'
          else
            score = party_scores.sum / promise_parties.size.to_f
            override = if score <= 33.33
                         0
                       elsif score < 66.66
                         50
                       else
                         100
                       end

            if pc.for?
              pc.override = override
            elsif pc.against?
              pc.override = (100 - override)
            end
          end

          pc.save!
        end

        issue.save!
      end
    end
  end
end
