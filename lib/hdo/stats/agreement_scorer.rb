module Hdo
  module Stats
    class AgreementScorer
      VALID_UNITS = [:propositions, :votes]

      def initialize(opts = {})
        @votes = opts[:votes] || Vote.with_results

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
            next if ignored?(vote)
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

            combinations.each do |current_parties|
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

      def combinations
        @combinations ||= (
          parties = Party.all.to_a
          combinations = []

          2.upto(parties.size) do |n|
            combinations.concat parties.combination(n).to_a
          end

          combinations
        )
      end

      def agree?(parties, stats)
        parties.map { |party| stats.text_for(party) }.uniq.size == 1
      end

      def ignored?(vote)
        vote.non_personal? && vote.subject =~ /lovens overskrift og loven i sin helhet/i
      end

    end
  end
end