# encoding: UTF-8

module Hdo
  module Views
    # TODO: i18n + specs

    class IssueVote
      def initialize(vote_connection, party_groups)
        @vote_connection = vote_connection
        @party_groups = party_groups
      end

      def vote
        @vote ||= @vote_connection.vote
      end

      def enacted_text
        @vote.enacted_text
      end

      def weight
        @vote_connection.weight
      end

      def enacted_class
        "label-#{enacted? ? 'success' : 'important'}"
      end

      def weight_text
        case weight
        when 0
          'Uten formell betydning'
        when 0.5
          'Lite viktig'
        when 1
          'Mindre viktig'
        when 2
          'Viktig'
        when 4
          'Svært viktig'
        else
          raise "unknown weight: #{@vote_connection.weight}"
        end
      end

      def matches_text
        @vote_connection.matches_text
      end

      def description
        @vote_connection.description
      end

      def comment
        @vote_connection.comment
      end

      def enacted?
        vote.enacted?
      end

      def parties
        @party_groups.map { |e| e.parties }.flatten.map { |e| PartyDetail.new(e, vote.stats) }
      end

      class PartyDetail
        def initialize(party, stats)
          @party = party
          @stats = stats
        end

        def logo
          @party.image_with_fallback
        end

        def counts
        counts = @stats.party_counts_for(@party)

        "#{counts[:for]} for, #{counts[:against]} mot, #{counts[:absent]} ikke tilstede"
        end

        def text
          "#{@party.name} #{@stats.text_for(@party)}"
        end
      end

    end # IssueVote
  end # Views
end # Hdo