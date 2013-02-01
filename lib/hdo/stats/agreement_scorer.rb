module Hdo
  module Stats
    class AgreementScorer

      def initialize(votes = Vote.with_results)
        @votes = votes
      end

      def result
        @result ||= (
          result = Hash.new(0)
          count  = 0

          @votes.each do |vote|
            next if ignored?(vote)

            count += 1
            stats = vote.stats

            combinations.each do |current_parties|
              if agree?(current_parties, stats)
                key = current_parties.map(&:external_id).sort.join(',')
                result[key] += 1
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