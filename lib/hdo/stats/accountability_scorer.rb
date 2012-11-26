module Hdo
  module Stats
    class AccountabilityScorer
      def self.all
        all = Hash.new { |hash, key| hash[key] = [] }

        Issue.published.each do |issue|
          issue.accountability.each { |party, issue_score| all[party] << issue_score }
        end

        totals = {}

        all.each do |party, issue_scores|
          totals[party] = issue_scores.sum / issue_scores.size.to_f
        end

        totals
      end

      def self.print(io = $stdout)
        all.sort_by { |_, score| score }.reverse.each { |party, score| puts "#{party.name}: #{score.to_i}%" }
      end

      attr_reader :total

      def initialize(issue)
        @data, @total = compute(issue)
      end

      def score_for(party)
        @data[party]
      end

      def each(&blk)
        @data.each(&blk)
      end

      private

      def compute(issue)
        vote_scores         = issue.stats
        promise_connections = issue.promise_connections.includes(:promise => :parties)

        percentages     = Hash.new
        scores_by_party = Hash.new { |hash, key| hash[key] = [] }

        promise_connections.each do |conn|
          party_scores_for(vote_scores, conn).each do |party, score|
            scores_by_party[party] << score
          end
        end

        scores_by_party.each do |party, scores|
          percentages[party] = scores.sum / scores.size.to_f
        end

        percentages
      end

      def party_scores_for(vote_scores, promise_connection)
        scores = {}

        promise_connection.promise.parties.each do |party|
          if promise_connection.for?
            scores[party] = vote_scores.score_for(party)
          elsif promise_connection.against?
            scores[party] = (100 - vote_scores.score_for(party))
          end
        end

        scores
      end

    end
  end
end