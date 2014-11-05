module Hdo
  module Utils
    class TwitterStats
      def initialize(opts = {})
        @client = TwitterClients.hdo
      end

      def display
        stats.each { |k, v| puts "#{k}: #{v}" }
      end

      def stats
        @stats ||= (
          tries = 0

          begin
            fetch_stats
          rescue
            tries < 3 ? retry : raise
          end
        )
      end

      private

      def fetch_stats
        data = {}

        usernames = {'holderdeord' => 'holderdeord'}

        representatives = Representative.with_twitter
        representatives.each do |rep|
          usernames[rep.twitter_id] = rep.slug
        end

        usernames.keys.sort.each_slice(50) do |slice|
          @client.users(slice).each do |user|
            slug = usernames[user.screen_name] || next

            data["twitter.#{slug}.followers"] = user.followers_count
            data["twitter.#{slug}.following"] = user.friends_count
            data["twitter.#{slug}.tweets"]    = user.tweets_count
          end
        end

        data

      end
    end
  end
end
