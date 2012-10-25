module Hdo
  module Model

    #
    # including model must define #fetch_stats
    #
    # for callbacks that should clear the cache, call #clear_stats_cache

    module HasStatsCache
      def stats
        Rails.cache.fetch(stats_cache_key) { fetch_stats }
      end

      private

      def clear_stats_cache(obj)
        Rails.cache.delete stats_cache_key
      end

      def stats_cache_key
        "#{cache_key}/stats"
      end
    end

  end
end