module Hdo
  module Stats
    class Rebels
      include Enumerable

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
