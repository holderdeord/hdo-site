# encoding: UTF-8

module Hdo
  module Stats
    class VoteScorer
      def initialize(model)
        @data = compute(model.vote_connections.includes(vote: {vote_results: {representative: {party_memberships: :party}}}))
      end

      def score_for(entity)
        @data[entity]
      end

      def text_score_for(entity)
        s = score_for(entity)
        s ? "#{s.to_i}%" : I18n.t('app.uncertain')
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

      def text_for(entity, opts = {})
        entity_name = opts[:name] || entity.name
        score = score_for(entity)

        text_for_entity score, entity_name, opts
      end

      def text_for_group(entities, opts = {})
        entity_name = opts.fetch(:name)
        score = score_for_group(entities)

        text_for_entity score, entity_name, opts
      end

      private

      def text_for_entity(score, entity_name, opts)
        if score.nil?
          return I18n.t("app.votes.scores.not_participated", name: entity_name).html_safe
        end

        # if you change the scoring, remember to change the 'about method' page as well.
        key = case score
              when 0...21
                :against
              when 21...41
                :mostly_against
              when 41...61
                :for_and_against
              when 61...81
                :mostly_for
              when 81..100
                :for
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

        sums = Hash.new(0)

        vote_percentages.each do |data|
          data.each do |entity, percent|
            sums[entity] += percent
          end
        end

        result = {}

        sums.each do |entity, total|
          if weight_sum.zero?
            result[entity] = 0
          else
            result[entity] = (total * 100 / weight_sum).to_i
          end
        end

        result
      end

      private

      def vote_percentages_for(vote_connection)
        vote         = vote_connection.vote
        vote_results = vote.vote_results
        by_party     = vote_results.group_by { |v| v.representative.party_at(vote.time) }
        res          = {}

        meth = vote_connection.matches? ? :for? : :against?

        by_party.each do |party, votes|
          for_count, against_count = 0, 0

          votes.each do |vote_result|
            next if vote_result.absent?

            if vote_result.__send__(meth)
              res[vote_result.representative] = vote_connection.weight
              for_count += 1
            else
              res[vote_result.representative] = 0
              against_count += 1
            end
          end

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
