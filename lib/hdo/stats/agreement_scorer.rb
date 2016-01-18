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

      def self.summary(opts = {})
        data, total = new(opts).result.values_at(:data, :total)
        data.map do |combo, count|
          {combination: combo, percentage: (count * 100 / total.to_f).round(1), total: total, count: count }
        end.sort_by { |e| e[:percentage] }
      end

      def self.csv_summary(opts = {})
        CSV.generate do |csv|
          csv << ["combination", "agreed_count", "total_count", "percentage"]
          summary(opts).sort_by { |e| e[:percentage] }.each do |entry|
            csv << entry.values_at(:combination, :count, :total, :percentage)
          end
        end
      end

      def self.csv_by_month(votes = Vote.all)
        groups = votes.group_by { |e| e.time.strftime("%Y-%m") }

        combos       = [%w[FrP H], %w[FrP H KrF V], %w[A Sp SV]].map { |e| e.sort }
        party_combos = combos.map { |combo| combo.map { |e| Party.find_by_external_id(e) } }

        result = Hash.new { |hash, key| hash[key] = {} }

        groups.each do |time, votes|
          data, total_count = new(votes: votes, combinations: party_combos).result.values_at(:data, :total)
          data.each do |combo, vote_count|
            result[time][combo] = {count: vote_count, total: total_count}
          end
        end

        CSV.generate do |csv|
          csv << ['month', 'unit_count', *combos.map { |e| e.join(',') }]

          result.sort_by { |time, _| time.split('-').map(&:to_i) }.each do |time, data|
            month_totals      = []
            month_percentages = []

            combos.each do |combo|
              d = data.fetch(combo.join(','))

              month_totals << d[:total]
              month_percentages << (d[:count] / d[:total].to_f) * 100
            end

            if month_totals.uniq.size > 1
              raise "total units varies by party combo for #{time.inspect}: #{month_totals.inspect}"
            end

            csv << [time, month_totals.first, *month_percentages]
          end
        end
      end

      def self.csv(opts = {})
        all               = new(opts).result
        parliament_issues = opts[:votes] ? opts[:votes].flat_map(&:parliament_issues) : ParliamentIssue.all
        categories        = by_category(parliament_issues)

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
        @votes            = opts[:votes] || Vote.with_results.includes(:propositions)
        @combinations     = opts[:combinations] || COMBINATIONS
        @ignore_unanimous = !!opts[:ignore_unanimous]

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
            next if ignore?(vote)

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

            @combinations.each do |current_parties|
              key = current_parties.map(&:external_id).sort.join(',')

              if agree?(current_parties, stats)
                result[key] += unit_count
              else
                result[key] += 0
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
        parties.all? { |party| stats.party_participated?(party) } &&
          parties.map { |party| stats.key_for(party) }.uniq.size == 1
      end

      def all_parties
        @all_parties ||= Party.all.to_a
      end

      def ignore?(vote)
        @ignore_unanimous && (vote.non_personal? || agree?(
          all_parties.select { |party| vote.stats.party_participated?(party) },
          vote.stats
        ))
      end

    end
  end
end