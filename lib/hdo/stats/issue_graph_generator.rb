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
              name: conn.description,
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
              links << {
                source: party_idx,
                target: party_count + conn_idx,
                value: value_for(party, conn.vote)
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
        @votes ||= @issue.vote_connections.order(:description).to_a
      end

      def value_for(party, vote)
        counts = vote.stats.party_counts_for(party)

        # does not consider absent representatives
        percent = counts[:for] * 100 / (counts[:for] + counts[:against]).to_f
        percent.to_i
      end

    end
  end
end