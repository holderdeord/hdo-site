module Hdo
  module Stats
    class AccountabilityScorer
      def self.score(issues = Issue.published)
        all = Hash.new { |hash, key| hash[key] = [] }

        issues.each do |issue|
          issue.accountability.data.each { |party, issue_score| all[party] << issue_score }
        end

        totals = {}
        all.each { |party, issue_scores| totals[party] = issue_scores.sum / issue_scores.size.to_f }

        totals
      end

      def self.category_score(issues = Issue.published)
        category_to_issues = Hash.new { |h,k| h[k] = [] }
        issues.each do |issue|
          issue.categories.each { |c| category_to_issues[c.name] << issue }
        end

        category_to_scores = {}
        category_to_issues.each do |cat, issues|
          category_to_scores[cat] = score(issues)
        end

        category_to_scores
      end

      def self.print_by_category(io = $stdout)
        category_score.each do |category, scores|
          puts category
          puts "=" * category.size

          scores.sort_by { |_, score| -score }.each { |party, score| puts "#{party.name.ljust(25)}: #{score.to_i}%" }

          puts
        end
      end

      def self.print(io = $stdout)
        score.sort_by { |_, score| -score }.each { |party, score| puts "#{party.name.ljust(25)}: #{score.to_i}%" }
      end

      attr_reader :total, :data

      def initialize(issue)
        @data = compute(issue)
      end

      def score_for(party)
        @data[party]
      end

      def text_score_for(party)
        s = score_for(party)
        s ? "#{s.to_i}%" : I18n.t('app.uncertain')
      end

      def as_json(opts = nil)
        @data.each_with_object({}) do |(party, score), obj|
          obj[party.name] = score
        end
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