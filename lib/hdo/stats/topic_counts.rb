module Hdo
  module Stats
    class TopicCounts
      include Enumerable

      def initialize(model)
        @model = model
      end

      def each(&blk)
        data.each(&blk)
      end

      def as_json(opts = {})
        data.map { |e| [e[0].name, e[1]] }.to_json
      end

      private

      def data
        @data ||= compute
      end

      def compute
        vote_percentages = @model.vote_connections.map do |vote_direction|
          vote_percentages_for(vote_direction)
        end

        result = Hash.new(0)

        vote_percentages.each do |data|
          data.each do |party, percent|
            result[party] += percent
          end
        end

        result.map do |party, total|
          [party, (total * 100 / vote_percentages.size)]
        end.sort_by { |party, percentage| party.name }
      end

      private

      def vote_percentages_for(vote_direction)
        vote_results = vote_direction.vote.vote_results.group_by { |v| v.representative.party }

        res = {}

        vote_results.each do |party, votes|
          meth = vote_direction.matches? ? :for? : :against?

          for_count, against_count = votes.reject(&:absent?).partition(&meth).map(&:size)
          total = (for_count + against_count)

          if total.zero?
            res[party] = 0
          else
            res[party] = for_count / total
          end
        end

        res
      end
    end
  end
end
