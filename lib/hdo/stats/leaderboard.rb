module Hdo
  module Stats
    class Leaderboard

      def initialize(issues)
        @data = compute(issues)
      end

      def fetch(key)
        list = @data[key] || {}
        list.sort_by { |party, count| -count }
      end

      private

      def compute(issues)
        parties = Party.all
        counts = Hash.new { |hash, key| hash[key] = Hash.new(0) }

        issues.each do |issue|
          acc = issue.accountability
          parties.each do |party|
            counts[acc.key_for(party)][party] += 1
          end
        end

        counts
      end

    end
  end
end