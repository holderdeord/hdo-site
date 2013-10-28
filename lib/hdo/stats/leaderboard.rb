module Hdo
  module Stats
    class Leaderboard
      attr_reader :by_party, :by_key, :issue_count

      def initialize(issues)
        @issue_count = issues.size

        parties = Party.order(:name)

        @government = Government.for_date(Date.new(2009, 10, 1)).first.try(:parties) || []
        @opposition = parties.to_a - @government

        @by_party = Hash.new { |hash, key| hash[key] = Hash.new(0) }
        @by_key = Hash.new { |hash, key| hash[key] = Hash.new(0) }

        issues.each do |issue|
          acc = issue.accountability
          parties.each do |party|
            @by_party[party][acc.key_for(party)] += 1
            @by_key[acc.key_for(party)][party] += 1
          end
        end
      end

      def parties
        [@government, @opposition].map do |group|
          group.map { |party|
            scores = @by_party[party]

            if scores[:kept] + scores[:broken] > 0
              [party, scores]
            end
          }.compact
        end
      end
    end
  end
end