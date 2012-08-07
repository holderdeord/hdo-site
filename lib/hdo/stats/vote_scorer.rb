# encoding: UTF-8

module Hdo
  module Stats
    class VoteScorer
      include Enumerable

      def initialize(model)
        @data = compute(model.vote_connections.includes(:vote))
      end

      def score_for(party)
        @data[party]
      end

      def score_for_group(parties)
        @data[parties] ||= parties.inject(0) { |score, party| score += @data[party] } / parties.count
      end

      def text_for(party, opts = {})
        entity_name = opts[:name] || party.name
        score = score_for(party)

        text_for_entity score, entity_name, opts
      end

      def text_for_group(parties, opts = {})
        entity_name = opts.fetch(:name)
        score = score_for_group(parties)

        text_for_entity score, entity_name, opts
      end

      private

      def text_for_entity(score, entity_name, opts)
        # TODO: i18n
        if score.nil?
          return "#{entity_name} har ikke deltatt i avstemninger om tema".html_safe
        end

        tmp = if opts[:html]
                "#{entity_name} har stemt <strong>%s</strong>"
              else
                "#{entity_name} har stemt %s"
              end

        res = case score
              when 0...33
                tmp % "mot"
              when 33...66
                tmp % "både for og mot"
              when 66..100
                tmp % "for"
              else
                raise "unknown score: #{score.inspect}"
              end

        res.html_safe
      end

      def compute(connections)
        weight_sum = 0
        vote_percentages = connections.map do |vote_connection|
          weight_sum += vote_connection.weight
          vote_percentages_for(vote_connection)
        end

        party_totals = Hash.new(0)

        vote_percentages.each do |data|
          data.each do |party, percent|
            party_totals[party] += percent
          end
        end

        result = {}

        party_totals.each do |party, total|
          result[party] = (total * 100 / weight_sum)
        end

        result
      end

      private

      def vote_percentages_for(vote_connection)
        vote_results = vote_connection.vote.vote_results.includes(:representative => :party)
        by_party = vote_results.group_by { |v| v.representative.party }

        res = {}

        by_party.each do |party, votes|
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
