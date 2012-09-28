# encoding: UTF-8

module Hdo
  module Stats
    class VoteScorer
      def initialize(model)
        @data = compute(model.vote_connections.includes(:vote))
      end

      def score_for(party)
        @data[party]
      end

      def score_for_group(parties)
        @data[parties] ||= (
          if parties.size.zero?
            nil
          else
            parties.map { |party| @data[party] || 0 }.sum / parties.size
          end
        )
      end

      def as_json(opts = nil)
        res = {}

        @data.each do |key, value|
          name = case key
                 when Array
                   key.map { |e| e.name }.join(',')
                 else
                   key.name
                 end

         res[name] = value
        end

        res
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
        if score.nil?
          return I18n.t("app.votes.scores.not_participated", name: entity_name).html_safe
        end

        key = case score
              when 0...6
                :consistently_against
              when 6...24
                :mostly_against
              when 24...42
                :partly_against
              when 42...60
                :for_and_against
              when 60...78
                :partly_for
              when 78...96
                :mostly_for
              when 96..100
                :consistently_for
              else
                raise "unknown score: #{score.inspect}"
              end

        key = "app.votes.scores.#{key}"
        key << "_html" if opts[:html]

        I18n.t(key, name: entity_name).html_safe
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
          if weight_sum.zero?
            result[party] = 0
          else
            result[party] = (total * 100 / weight_sum).to_i
          end
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
            res[party] = (for_count / total.to_f) * vote_connection.weight
          end
        end

        res
      end
    end
  end
end
