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

      def key_for(party)
        score = score_for(party)

        case score
        when nil
          :unclear
        when 0...50
          :broken
        when 50..100
          :kept
        else
          raise "score out of range: #{score.inspect}"
        end
      end

      def text_for(party)
        # TODO: tests, html as option
        I18n.t("app.promises.scores.#{key_for(party)}_html", name: party.name).html_safe
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
            scores_by_party[party] << score if score
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
          party_score = vote_scores.score_for(party)

          if party_score.nil?
            scores[party] = nil
          elsif promise_connection.for?
            scores[party] = party_score
          elsif promise_connection.against?
            scores[party] = (100 - party_score)
          end
        end

        scores
      end

    end
  end
end