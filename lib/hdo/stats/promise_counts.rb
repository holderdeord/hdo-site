require 'csv'

module Hdo
  module Stats
    class PromiseCounts
      def initialize(promises = nil)
        @promises = promises || ParliamentPeriod.current.promises
      end

      def by_category(only_main)
        result = Hash.new { |hash, category| hash[category] = [] }

        @promises.each do |promise|
          if only_main
            cats = promise.categories.map { |cat| cat.main? ? cat : cat.parent }.uniq
          else
            cats = promise.categories
          end

          cats.each { |c| result[c] << promise }
        end

        result
      end

      def csv(only_main = true)
        parties = Party.order(:name)

        CSV.generate do |csv|
          csv << ["", "Snitt", *parties.map(&:external_id)]

          by_category(only_main).each do |category, promises|
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

            csv << [category_name(category), avg, *parties.map { |e| by_party_counts[e] }]
          end
        end
      end

      private

      def category_name(category)
        category.main? ? category.name : "#{category.name} (#{category.parent.name})"
      end

    end
  end
end
