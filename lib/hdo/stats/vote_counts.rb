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
          approve: for_count,
          against: against_count,
          absent:  absent_count,
          parties: Hash[@party_counts.map { |party, counts| [party && party.name, counts] }],
          groups: groups.inject({}) { |a, (k,v)| a.merge(k => v.compact.map { |p| {name: p.name, slug: p.slug } }) }
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
        (count * 100 / (total.zero? ? 1 : total).to_f).round
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
        counts = party_counts_for(party)
        counts[:against] > counts[:for]
      end

      def party_absent?(party)
        counts = party_counts_for(party)
        counts[:absent] > 0 && (counts[:for] == 0 && counts[:against] == 0)
      end

      def party_split?(party)
        counts = party_counts_for(party)
        counts[:for] == counts[:against] && (counts[:for] > 0)
      end

      def text_for(party)
        return VoteResult.human_attribute_name 'voted_for' if party_for?(party)
        return VoteResult.human_attribute_name 'voted_against' if party_against?(party)
        return VoteResult.human_attribute_name 'voted_neither' unless party_participated?(party)
        return VoteResult.human_attribute_name 'voted_neither' if party_split?(party)

        raise 'Vote counting error.'
      end

      def key_for(party)
        return :for if party_for?(party)
        return :against if party_against?(party)
        return :unknown unless party_participated?(party)
        return :split if party_split?(party)

        raise 'Vote counting error.'
      end

      def parties
        @party_counts.keys.select { |e| party_participated?(e) }
      end

      def groups
        res = {for: [], against: []}

        parties.each do |party|
          res[:for] << party if party_for?(party)
          res[:against] << party if party_against?(party)
        end

        res
      end

      private

      def compute_party_counts(vote)
        time = vote.time

        vote_results = VoteResult.pluck_all(vote.vote_results, :representative_id, :result)

        results_by_party_id = vote_results.group_by do |vr|
          rid = vr['representative_id']
          rep = Rails.cache.fetch("representatives/#{rid}") { Representative.find_by_id(rid) }
          rep.party_id_at(time)
        end

        res = {}

        results_by_party_id.each do |party_id, vrs|
          res[Party.by_id(party_id)] = counts_for(vrs)
        end

        res
      end

      def counts_for(vote_results)
        res = Hash.new(0)

        vote_results.each do |vote_result|
          res[VoteResult.state_for(vote_result['result'].to_i)] += 1
        end

        res
      end

    end
  end
end
