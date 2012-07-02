module Hdo
  module ModelHelpers
    module HasRepresentatives

      def percent_of_representatives
        total = Representative.count
        total = 1 if total.zero?

        representatives.size * 100 / total
      end

    end
  end
end