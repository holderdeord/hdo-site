module Hdo
  module Utils
    module TwitterClients

      def self.hdo
        Twitter::REST::Client.new do |config|
          config.consumer_key        = ENV.fetch('TWITTER_CONSUMER_KEY')
          config.consumer_secret     = ENV.fetch('TWITTER_CONSUMER_SECRET')
          config.access_token        = ENV.fetch('TWITTER_ACCESS_TOKEN')
          config.access_token_secret = ENV.fetch('TWITTER_ACCESS_TOKEN_SECRET')
        end
      end

      def self.partipisken
        Twitter::REST::Client.new do |config|
          config.consumer_key        = ENV.fetch('TWITTER_PP_CONSUMER_KEY')
          config.consumer_secret     = ENV.fetch('TWITTER_PP_CONSUMER_SECRET')
          config.access_token        = ENV.fetch('TWITTER_PP_ACCESS_TOKEN')
          config.access_token_secret = ENV.fetch('TWITTER_PP_ACCESS_TOKEN_SECRET')
        end
      end
    end
  end
end
