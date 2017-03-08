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
        data = new(opts).result
        data.map do |combo, entry|
          count = entry[:count]
          total = entry[:total]

          {
            combination: combo,
            percentage: (count * 100 / total.to_f).round(1),
            total: total,
            count: count
          }
        end.sort_by { |e| e[:percentage] }
      end

      def self.csv_summary(opts = {})
        CSV.generate(col_sep: "\t") do |csv|
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

        groups.each do |time, group_votes|
          data = new(votes: group_votes, combinations: party_combos).result
          data.each do |combo, entry|
            result[time][combo] = entry
          end
        end

        CSV.generate(col_sep: "\t") do |csv|
          csv << ['month', 'unit_count', *combos.map { |e| e.join(',') }]

          result.sort_by { |time, _| time.split('-').map(&:to_i) }.each do |time, data|
            month_totals      = []
            month_percentages = []

            combos.each do |combo|
              d = data.fetch(combo.join(','))

              month_totals << d[:total]
              month_percentages << (d[:count] / d[:total].to_f) * 100
            end

            csv << [time, month_totals.first, *month_percentages]
          end
        end
      end

      def self.csv(opts = {})
        all               = new(opts).result
        parliament_issues = opts[:votes] ? opts[:votes].flat_map(&:parliament_issues) : ParliamentIssue.all
        categories        = by_category(parliament_issues)
        combinations      = all.keys.sort

        table = []

        table << [nil, *combinations]
        table << ["Alle kategorier", *combinations.map { |key| '%.1f' % ((all[key][:count] / all[key][:total].to_f) * 100) }]

        categories.each do |name, result|
          table << [name, *combinations.map { |key| '%.1f' % ((result[key][:count] / result[key][:total].to_f) * 100) }]
        end

        CSV.generate(col_sep: "\t") do |csv|
          table.transpose.each { |row| csv << row }
        end
      end

      def initialize(opts = {})
        opts = opts.dup

        @votes               = opts.delete(:votes) || Vote.with_results.includes(:propositions)
        @combinations        = opts.delete(:combinations) || COMBINATIONS
        @ignore_unanimous    = !!opts.delete(:ignore_unanimous)
        @exclude_issue_types = opts.delete(:exclude_issue_types)

        unit = opts.delete(:unit)

        if unit
          unless VALID_UNITS.include?(unit)
            raise "invalid unit: #{unit.inspect}"
          end

          @unit = unit
        else
          @unit = :propositions
        end

        if opts.any?
          raise ArgumentError, "unknown options: #{opts.keys.inspect}"
        end
      end

      def result
        @result ||= (
          result = Hash.new { |hash, key| hash[key] = {count: 0, total: 0} }
          count  = 0

          @votes.each do |vote|
            next if ignore?(vote)

            stats = vote.stats

            case @unit
            when :propositions
              unit_count = vote.propositions.count
            when :votes
              unit_count = 1
            else
              raise "invalid unit: #{@unit.inspect}"
            end

            count += unit_count

            @combinations.each do |current_parties|
              key = current_parties.map(&:external_id).sort.join(',')

              if current_parties.all? { |party| stats.party_participated?(party)  }
                if agree?(current_parties, stats)
                  result[key][:count] += unit_count
                end

                result[key][:total] += unit_count
              end
            end
          end

          {}.merge(result) # avoid default proc for cache serialization
        )
      end

      def print(io = $stdout)
        data = result.sort_by { |combo, entry| -entry[:count] }

        data.each do |combo, entry|
          count = entry[:count]
          total = entry[:total]

          str = "%s: %.2f%% (%d/%d)" % [combo.ljust(20), (count * 100 / total.to_f), count, total]
          io.puts str
        end
      end

      private

      def agree?(parties, stats)
        parties.map { |party| stats.key_for(party) }.reject { |k| k == :split }.uniq.size == 1
      end

      def all_parties
        @all_parties ||= Party.all.to_a
      end

      def ignore?(vote)
        (
          @ignore_unanimous &&
            (vote.non_personal? || agree?(
              all_parties.select { |party| vote.stats.party_participated?(party) },
              vote.stats
            ))
        ) || (
          @exclude_issue_types && vote.parliament_issues.any? { |pi| @exclude_issue_types.include?(pi.issue_type) }
        )
      end

    end
  end
end