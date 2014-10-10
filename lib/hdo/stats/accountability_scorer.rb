# encoding: utf-8

require 'csv'

module Hdo
  module Stats
    class AccountabilityScorer
      def self.csv
        parties = Party.order(:name).to_a

        rows = []

        all_issues = Issue.published.order(:title)
        all_issues.each do |issue|
          ac = issue.accountability
          scores = parties.map { |p| ac.score_for(p) }.map { |e| e ? e.to_i : nil }
          rows << [issue.title, nil, *scores]
        end

        totals = score(all_issues)

        CSV.generate do |csv|
          csv << [nil, nil, *parties.map(&:name)]
          csv << ['Snitt alle partier/saker', totals[:aggregate].to_i]
          csv << ['Snitt alle saker', nil, *parties.map { |p| totals[p] ? totals[p].to_i : nil }]

          rows.each { |r| csv << r }
        end
      end

      def self.score(issues = Issue.published)
        all = Hash.new { |hash, key| hash[key] = [] }

        Array(issues).each do |issue|
          issue.accountability.data.each do |party, issue_score|
            all[:aggregate] << issue_score
            all[party] << issue_score
          end
        end

        totals = {}
        all.each { |party, issue_scores| totals[party] = issue_scores.sum / issue_scores.size.to_f }

        totals
      end

      def self.category_score(issues = Issue.published)
        category_to_issues = Hash.new { |h,k| h[k] = [] }
        Array(issues).each do |issue|
          issue.categories.each { |c| category_to_issues[c.name] << issue }
        end

        category_to_scores = {}
        category_to_issues.each do |cat, iss|
          category_to_scores[cat] = score(iss)
        end

        category_to_scores
      end

      def self.csv_by_category
        parties = Party.order(:name)

        CSV.generate { |csv|
          csv << [nil, *parties.map(&:name)]

          category_score.sort_by { |c, _| c }.each do |category, scores|
            csv << [category, *parties.map { |p| (score = scores[p]) ? score.to_i : nil }]
          end
        }
      end

      attr_reader :total, :data

      def initialize(issue, parliament_period = nil)
        @data = compute(issue, parliament_period)
      end

      #
      # Float = accountability score
      # NaN   = party has relevant promises, but no votes
      # Nil   = party has no relevant promises
      #
      # @return [Float, Nan, Nil]
      #

      def score_for(party)
        @data[party]
      end

      def text_score_for(party)
        s = score_for(party)
        s ? "#{s.to_i}%" : I18n.t('app.uncertain')
      end

      def key_for(party)
        score = score_for(party)

        if score.nil?
          return :no_promises
        end

        if score.nan?
          return :unknown
        end

        if score < 0 || score > 100
          raise "score out of range: #{score.inspect}"
        end

        if score <= 33.33
          :broken
        elsif score < 66.66
          :partially_kept
        else
          :kept
        end
      end

      def text_for(party, opts = {})
        # TODO: tests, html as option
        name = opts[:name] || party.name

        I18n.t("app.promises.scores.#{key_for(party)}_html", name: name).html_safe
      end

      def as_json(opts = nil)
        @data.each_with_object({}) do |(party, score), obj|
          obj[party.name] = score
        end
      end

      private

      def compute(issue, parliament_period = nil)
        promise_connections = issue.promise_connections.includes(:promise)

        if parliament_period
          promise_connections = promise_connections.where('promises.parliament_period_id' => parliament_period.id)
        end

        percentages         = {}
        scores_by_party     = {}

        promise_connections.each do |conn|
          party_scores_for(conn).each do |party, score|
            scores_by_party[party] ||= []
            scores_by_party[party] << score if score
          end
        end

        scores_by_party.each do |party, scores|
          percentages[party] = scores.sum / scores.size.to_f
        end

        percentages
      end

      def party_scores_for(promise_connection)
        scores = {}

        promise_connection.promise.parties.each do |party|
          if promise_connection.related?
            next
          elsif promise_connection.kept?
            scores[party] = 100
          elsif promise_connection.partially_kept?
            scores[party] = 50
          elsif promise_connection.broken?
            scores[party] = 0
          else
            scores[party] = nil
          end
        end

        scores
      end

    end
  end
end
