module Hdo
  module Stats
    class IssueGraphGenerator

      def initialize(issue)
        @issue = issue
      end

      def as_json(opts = nil)
        {
          title: @issue.title,
          graph: {
            nodes: nodes,
            links: links
          }
        }
      end

      private

      def nodes
        @nodes ||= (
          nodes = []

          parties.each do |party|
            nodes << {
              name: party.name,
              group: 1
            }
          end

          vote_connections.each do |conn|
            nodes << {
              name: conn.title,
              group: 2
            }
          end

          nodes
        )
      end

      def links
        @links ||= (
          links = []

          party_count = parties.size
          parties.each_with_index do |party, party_idx|
            vote_connections.each_with_index do |conn, conn_idx|
              value = value_for(party, conn)
              next if value <= 0

              links << {
                source: party_idx,
                target: party_count + conn_idx,
                value: value
              }

            end
          end

          links
        )
      end

      def parties
        @parties ||= Party.order(:name).to_a
      end

      def vote_connections
        @votes ||= @issue.vote_connections.order(:title).to_a
      end

      def value_for(party, vote_connection)
        counts = vote_connection.vote.stats.party_counts_for(party)

        s = counts[:for]
        t = counts[:for] + counts[:against]
        v = vote_connection.weight

        v * s / t
      end

    end
  end
end