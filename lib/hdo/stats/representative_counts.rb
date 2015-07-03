module Hdo
  module Stats
    class RepresentativeCounts

      def self.attendance_for_votes(votes, opts = {})
        data = votes.
          flat_map(&:vote_results).
          group_by(&:representative).
          inject({}) do |mem, (rep, vote_results)|
            mem.merge(rep => new(vote_results).as_json)
          end

        if opts[:csv]
          require 'csv'

          CSV.generate(col_sep: "\t") do |csv|
            columns = data.first.last.keys
            csv << ['representative_name', *columns]

            data.each do |rep, counts|
              csv << [rep.name, *columns.map { |c| counts[c] }]
            end
          end
        else
          data
        end
      end

      def initialize(vote_results)
        @data = vote_results.group_by(&:result)
      end

      def absent_count
        Array(@data[0]).size
      end

      def for_count
        Array(@data[1]).size
      end

      def against_count
        Array(@data[-1]).size
      end

      def absent_percent
        absent_count * 100 / total_count.to_f
      end

      def for_percent
        for_count * 100 / total_count.to_f
      end

      def against_percent
        against_count * 100 / total_count.to_f
      end

      def total_count
        @total ||= (
          t = @data.values.flatten.size
          t = -1 if t.zero?

          t
        )
      end

      def as_json(opts = nil)
        {
          absent_count: absent_count,
          for_count: for_count,
          against_count: against_count,
          absent_percent: absent_percent,
          for_percent: for_percent,
          against_percent: against_percent,
          total_count: total_count
        }
      end
    end
  end
end