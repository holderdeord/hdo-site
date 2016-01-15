require 'csv'

module Hdo
  module Stats
    class VoteExporter
      def initialize(votes = Vote.all)
        @votes = votes
      end

      def csv
        parties = Party.order(:external_id).to_a

        CSV.generate(col_sep: "\t") do |csv|
          csv << %w[id time session] + parties.map(&:external_id)

          @votes.each do |vote|
            stats = vote.stats
            csv << [vote.slug, vote.time.localtime.iso8601, vote.parliament_session.name] + parties.map { |p| stats.key_for(p) }
          end
        end
      end

      def print
        puts csv
      end
    end
  end
end