module Hdo
  module Stats
    class Leaderboard
      attr_reader :by_party, :by_key, :issue_count

      def initialize(issues, parliament_period)
        @by_party          = Hash.new { |hash, key| hash[key] = Hash.new(0) }
        @by_key            = Hash.new { |hash, key| hash[key] = Hash.new(0) }

        @issue_count       = issues.size
        @parliament_period = parliament_period

        @government = []
        @opposition = []

        calculate
      end

      def parliament_period_name
        @parliament_period.try(:name)
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

      private

      def calculate
        return unless @parliament_period

        parties = Party.order(:name)

        @government = Government.for_date(@parliament_period.start_date + 2.months).first.try(:parties) || []
        @opposition = parties.to_a - @government

        issues.each do |issue|
          acc = issue.accountability(@parliament_period)
          parties.each do |party|
            @by_party[party][acc.key_for(party)] += 1
            @by_key[acc.key_for(party)][party] += 1
          end
        end
      end

    end
  end
end