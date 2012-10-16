# encoding: UTF-8

module Hdo
  module Views
    # TODO: i18n + specs

    class IssueVote
      def initialize(vote_connection, party_groups)
        @vote_connection = vote_connection
        @party_groups = party_groups
      end

      def enacted_text
        # TODO: i18n
        str = "Forslaget ble <strong>"

        if enacted?
          str << "vedtatt"
        else
          str << "ikke vedtatt"
        end

        str << "</strong>."

        str
      end

      def time_text
        I18n.l time, format: :text
      end

      def time
        vote.time
      end

      def matches_text
        # TODO: i18n
        str = 'Avstemningen er <strong>'
        str << 'ikke ' unless matches?
        str << "i tråd med å #{issue.downcased_title}</strong>."

        str
      end

      def weight_text
        @vote_connection.weight_text
      end

      def parties_for
        @parties_for ||= all_parties.select { |e| vote.stats.party_for?(e) }
      end

      def parties_against
        @parties_against ||= all_parties.select { |e| vote.stats.party_against?(e) }
      end

      def vote
        @vote ||= @vote_connection.vote
      end

      def description
        @vote_connection.description
      end

      def comment
        @vote_connection.comment
      end

      private

      def issue
        @issue ||= @vote_connection.issue
      end

      def enacted?
        vote.enacted?
      end

      def matches?
        @vote_connection.matches?
      end

      def all_parties
        @all_parties ||= @party_groups.map { |e| e.parties }.flatten
      end

    end # IssueVote
  end # Views
end # Hdo