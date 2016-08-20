require 'hashie/mash'

module Hdo
  module Stats
    class Rebels
      include Enumerable

      def self.stats_for(votes)
        stats = Hashie::Mash.new(
          representatives: {}
        )

        new(votes).each do |vote, rebel_vote_results|
          rebel_vote_results.each do |vr|
            rep = vr.representative
            vote = vr.vote

            data = stats.representatives[rep.slug] ||= Hashie::Mash.new(
              name: rep.name,
              party: {
                name: rep.current_party.name,
                slug: rep.current_party.slug
              },
              rebel_votes: []
            )

            data.rebel_votes << {
              time: vote.time.strftime("%Y-%m-%d"),
              id: vote.id
            }
          end
        end

        stats
      end

      def initialize(votes)
        @votes = votes
      end

      def each(&each)
        @votes.each do |vote|
          rebels = rebels_for(vote)

          yield [vote, rebels] if rebels.any?
        end
      end

      private

      def rebels_for(vote)
        rebels   = []
        by_party = vote.
          vote_results.
          includes(:representative => {:party_memberships => :party}).
          reject(&:absent?).
          group_by { |vr| vr.representative.party_at(vote.time) }

        by_party.each do |party, vote_results|
          counts = Hash.new(0)
          vote_results.each { |vr| counts[vr.state] += 1 }

          if counts.values.sum > 3 && counts[:for] != counts[:against]
            majority_state = counts[:for] > counts[:against] ? :for : :against

            vote_results.each do |vr|
              rebels << vr if !vr.absent? && vr.state != majority_state
            end
          end
        end

        rebels
      end
    end
  end
end
