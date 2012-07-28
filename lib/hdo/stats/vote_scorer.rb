# encoding: UTF-8

module Hdo
  module Stats
    class VoteScorer
      include Enumerable

      def initialize(model)
        @model = model
      end

      def each(&blk)
        data.each(&blk)
      end

      def score_for(party)
        data[party]
      end

      def text_for(party)
        # TODO: i18n
        score = score_for(party)

        case score
        when 0..33
          "#{party.name} har stemt mot"
        when 34..66
          "#{party.name} har stemt både for og mot"
        when 67..100
          "#{party.name} har stemt for"
        else
          "#{party.name} har ikke deltatt i avstemninger om tema"
        end
      end

      private

      def data
        @data ||= compute
      end

      def compute
        vote_percentages = @model.vote_connections.map do |vote_connection|
          vote_percentages_for(vote_connection)
        end

        party_percentages = Hash.new(0)

        vote_percentages.each do |data|
          data.each do |party, percent|
            party_percentages[party] += percent
          end
        end

        result = {}

        party_percentages.each do |party, total|
          result[party] = (total * 100 / vote_percentages.size)
        end

        result
      end

      private

      def vote_percentages_for(vote_connection)
        vote_results = vote_connection.vote.vote_results.group_by { |v| v.representative.party }

        res = {}

        vote_results.each do |party, votes|
          meth = vote_connection.matches? ? :for? : :against?

          for_count, against_count = votes.reject(&:absent?).partition(&meth).map(&:size)
          total = (for_count + against_count)

          if total.zero?
            res[party] = 0
          else
            res[party] = (for_count / total) * vote_connection.weight
          end
        end

        res
      end
    end
  end
end
