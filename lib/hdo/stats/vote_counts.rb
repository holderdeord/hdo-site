module Hdo
  module Stats
    class VoteCounts
      attr_reader :for_count, :against_count, :absent_count

      def initialize(vote)
        @for_count     = vote.for_count     || 0
        @against_count = vote.against_count || 0
        @absent_count  = vote.absent_count  || 0
        @vote = vote
      end

      def as_json(opts = nil)
        {
          :approve => for_count,
          :against => against_count,
          :absent  => absent_count
        }
      end

      def vote_count
        @vote_count ||= for_count + against_count
      end

      def total_count
        @total_count ||= vote_count + absent_count
      end

      def for_percent
        @for_percent ||= percentage_of for_count, vote_count
      end

      def against_percent
        @against_percent ||= percentage_of against_count, vote_count
      end

      def absent_percent
        @absent_percent ||= percentage_of absent_count, total_count
      end

      def percentage_of(count, total)
        count * 100 / (total.zero? ? 1 : total)
      end

      def party_votes
        @party_votes ||= (
          party_results = @vote.vote_results.group_by { |r| r.representative.party }

          res = {}

          party_results.each do |party, vote_results|
            res[party] = counts_for(vote_results)
          end

          res
        )
      end

      def party_participated?(party)
        party_votes[party][:for] > 0 || party_votes[party][:against] > 0
      end

      def party_for?(party)
        party_votes[party][:for] > party_votes[party][:against]
      end

      def party_against?(party)
        !party_for?(party) && party_participated?(party)
      end

      def text_for(party)
        return VoteResult.human_attribute_name 'voted_for' if party_for?(party)
        return VoteResult.human_attribute_name 'voted_against' if party_against?(party)
        return VoteResult.human_attribute_name 'voted_neither' unless party_participated?(party)
        raise 'Vote counting error.'
      end

      private

      def counts_for(vote_results)
        res = Hash.new(0)
        vote_results.each do |vote_result|
          res[vote_result.state] += 1
        end

        res
      end
    end
  end
end
