require 'csv'

module Hdo
  module Stats
    class PromiseCounts
      def initialize(promises = nil)
        @promises = promises || ParliamentPeriod.current.promises
      end

      def by_main_category
        result = Hash.new { |hash, category| hash[category] = [] }

        @promises.each do |promise|
          cats = promise.categories.map { |cat| cat.main? ? cat : cat.parent }.uniq
          cats.each { |c| result[c] << promise  }
        end

        result
      end

      def csv
        parties = Party.order(:name)

        CSV.generate do |csv|
          csv << ["", "Snitt", *parties.map(&:external_id)]

          by_main_category.each do |category, promises|
            by_party_counts = Hash.new(0)

            promises.each do |promise|
              next if promise.parties.size > 1
              by_party_counts[promise.parties.first] += 1
            end

            if by_party_counts.size > 0
              avg = by_party_counts.values.sum / by_party_counts.size
            else
              avg = 0
            end

            csv << [category.name, avg, *parties.map { |e| by_party_counts[e] }]
          end
        end
      end

    end
  end
end
