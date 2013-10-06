module Hdo
  module Stats
    class VoteCounts
      attr_reader :for_count, :against_count, :absent_count

      def initialize(vote)
        @for_count     = vote.for_count     || 0
        @against_count = vote.against_count || 0
        @absent_count  = vote.absent_count  || 0

        @party_counts = compute_party_counts vote
      end

      def as_json(opts = nil)
        {
          :approve => for_count,
          :against => against_count,
          :absent  => absent_count,
          :parties => Hash[@party_counts.map { |party, counts| [party && party.name, counts] }]
        }
      end

      def vote_count
        for_count + against_count
      end

      def total_count
        vote_count + absent_count
      end

      def for_percent
        percentage_of for_count, vote_count
      end

      def against_percent
        percentage_of against_count, vote_count
      end

      def absent_percent
        percentage_of absent_count, total_count
      end

      def percentage_of(count, total)
        count * 100 / (total.zero? ? 1 : total)
      end

      def party_counts_for(party)
        @party_counts[party] || Hash.new(0)
      end

      def party_participated?(party)
        counts = party_counts_for(party)
        counts[:for] > 0 || counts[:against] > 0
      end

      def party_for?(party)
        counts = party_counts_for(party)
        counts[:for] > counts[:against]
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

      def parties
        @party_counts.keys.select { |e| party_participated?(e) }
      end

      private

      def compute_party_counts(vote)
        time = vote.time
        party_results = vote.vote_results.includes(representative: {party_memberships: :party}).group_by { |r| r.representative.party_at(time) }

        res = {}

        party_results.each do |party, vote_results|
          res[party] = counts_for(vote_results)
        end

        res
      end

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
