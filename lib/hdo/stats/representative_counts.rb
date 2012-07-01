module Hdo
  module Stats
    class RepresentativeCounts
      def initialize(model)
        @data = model.vote_results.group_by(&:result)
      end

      def absent_count
        Array(@data[0]).size
      end

      def for_count
        Array(@data[1]).size
      end

      def against_count
        Array(@data[-1]).size
      end

      def absent_percent
        absent_count * 100 / total_count
      end

      def for_percent
        for_count * 100 / total_count
      end

      def against_percent
        against_count * 100 / total_count
      end

      def total_count
        @total ||= (
          t = @data.values.flatten.size
          t = -1 if t.zero?

          t
        )
      end
    end
  end
end