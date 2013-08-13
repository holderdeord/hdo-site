require 'csv'

module Hdo
  module Stats
    class PartyAgreement

      def self.csv_by_month
        groups = Vote.all.group_by { |e| e.time.strftime("%Y-%m") }
        combos = [%w[FrP H], %w[FrP H KrF V], %w[A Sp SV]].map { |e| e.sort }

        result = Hash.new { |hash, key| hash[key] = {} }

        groups.each do |time, votes|
          data, total_count = new(votes, combinations: combos).result
          data.each do |combo, vote_count|
            result[time][combo.map(&:external_id).sort] = {count: vote_count, total: total_count}
          end
        end

        CSV.generate do |csv|
          csv << ['month', *combos.map { |e| e.join(',') }]

          result.sort_by { |time, _| time.split('-').map(&:to_i) }.each do |time, data|
            month_data = combos.map do |combo|
              d = data.fetch(combo)
              (d[:count] / d[:total].to_f) * 100
            end

            csv << [time, *month_data]
          end
        end
      end

      def initialize(votes, opts = {})
        @votes        = votes
        @combinations = extract_combinations(opts)
      end

      def result
        @result ||= (
          result = Hash.new(0)
          total_count = @votes.size

          @votes.each_with_index do |vote, idx|
            stats = vote.stats

            @combinations.each do |current_parties|
              key = current_parties.sort_by(&:name)
              if current_parties.map { |party| stats.text_for(party) }.uniq.size == 1
                result[key] += 1
              else
                result[key] += 0
              end
            end
          end

          [result.sort_by { |_, count| -count }, total_count]
        )
      end

      def csv
        CSV.generate do |csv|
          csv << ['party_combo', 'percent', 'agree_count', 'total_count']
          data, total_count = result

          data.each do |combo, vote_count|
            csv << [combo.map(&:external_id).join(','), (vote_count * 100 / total_count.to_f), vote_count, total_count]
          end
        end
      end

      def display(io = $stdout)
        data, total_count = result

        data.each do |combo, vote_count|
          io.puts "#{combo.map(&:external_id).join(',').ljust(20)}: #{vote_count}/#{total_count} (#{(vote_count / total_count.to_f) * 100}%)"
        end
      end

      private

      def extract_combinations(opts)
        if opts[:combinations]
          opts[:combinations].map do |parties|
            parties.map { |id| Party.find_by_external_id!(id) }
          end
        else
          parties = Party.all.to_a
          combos = 2.upto(parties.size).inject([]) { |m, n| m.concat parties.combination(n).to_a }
          combos.sort_by(&:size)
        end
      end

    end
  end
end
