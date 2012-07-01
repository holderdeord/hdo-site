module Hdo
  module Stats
    class VoteCounts
      attr_reader :for_count, :against_count, :absent_count

      def initialize(vote)
        @for_count     = vote.for_count     || 0
        @against_count = vote.against_count || 0
        @absent_count  = vote.absent_count  || 0
      end

      def as_json(opts = nil)
        {
          :for     => for_count,
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
    end
  end
end