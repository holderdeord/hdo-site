require 'csv'

module Hdo
  module Stats
    class AgreementScorer
      VALID_UNITS = [:propositions, :votes]

      COMBINATIONS = (
        parties = Party.all.to_a
        2.upto(parties.size).flat_map do |n|
          parties.combination(n).to_a
        end
      )

      def self.by_category(parliament_issues = ParliamentIssue.all)
        category_votes = Hash.new { |h, k| h[k] = [] }

        parliament_issues.each do |pi|
          pi.categories.each do |cat|
            cat = cat.main? ? cat : cat.parent
            category_votes[cat.human_name].concat pi.vote_ids
          end
        end

        result = {}

        category_votes.each do |category_name, vote_ids|
          votes = Vote.with_results.find(vote_ids.uniq)
          result[category_name] = new(votes: votes).result
        end

        result
      end

      def self.csv
        all        = new.result
        categories = by_category

        category_names = categories.keys.sort
        combinations = all[:data].keys.sort

        table = []

        table << [nil, *combinations]
        table << ["Alle kategorier", *combinations.map { |key| '%.1f' % ((all[:data][key] / all[:total].to_f) * 100) }]

        categories.each do |name, result|
          table << [name, *combinations.map { |key| '%.1f' % ((result[:data][key] / result[:total].to_f) * 100) }]
        end

        CSV.generate do |csv|
          table.transpose.each { |row| csv << row }
        end
      end

      def initialize(opts = {})
        @votes = opts[:votes] || Vote.with_results.includes(:propositions)

        if opts[:unit]
          unless VALID_UNITS.include?(opts[:unit])
            raise "invalid unit: #{opts[:unit].inspect}"
          end

          @unit = opts[:unit]
        else
          @unit = :propositions
        end
      end

      def result
        @result ||= (
          result = Hash.new(0)
          count  = 0

          @votes.each do |vote|
            stats = vote.stats

            case @unit
            when :propositions
              unit_count = vote.propositions.uniq.size
            when :votes
              unit_count = 1
            else
              raise "invalid unit: #{@unit.inspect}"
            end

            count += unit_count

            COMBINATIONS.each do |current_parties|
              if agree?(current_parties, stats)
                key = current_parties.map(&:external_id).sort.join(',')
                result[key] += unit_count
              end
            end
          end

          { :total => count, :data => result }
        )
      end

      def print(io = $stdout)
        total, data = result.values_at(:total, :data)
        data = data.sort_by { |combo, value| -value }

        data.each do |c, v|
          str = "%s: %.2f%% (%d/%d)" % [c.ljust(20), (v * 100 / total.to_f), v, total]
          io.puts str
        end
      end

      private

      def agree?(parties, stats)
        parties.map { |party| stats.text_for(party) }.uniq.size == 1
      end

    end
  end
end