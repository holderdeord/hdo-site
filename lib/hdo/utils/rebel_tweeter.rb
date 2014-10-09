# -*- coding: utf-8 -*-

module Hdo
  module Utils
    class RebelTweeter
      MIN_TWEET_INTERVAL = 60

      def self.since(date)
        new(date)
      end

      def initialize(start_date)
        @start_date = start_date
      end

      def print
        each_rebel_vote do |vote, vote_result|
          msg = message_for(vote, vote_result)
          puts "#{msg} (#{msg.size})"
        end
      end

      def tweet
        each_rebel_vote do |vote, vote_result|
          send_tweet message_for(vote, vote_result).truncate(140)
          sleep interval
        end
      end

      private

      def interval
        MIN_TWEET_INTERVAL + rand(MIN_TWEET_INTERVAL)
      end

      def message_for(vote, vote_result)
        representative = vote_result.representative
        party          = representative.party_at(vote.time)
        message        = "#{representative.full_name} (#{party.external_id}) stemte #{vote_result.human.downcase} #{vote.subject}"
        url            = helpers.vote_url(vote, host: 'www.holderdeord.no')

        [message.truncate(140 - url.length - 1), url].join(' ')
      end

      def each_rebel_vote(&blk)
        Vote.where('time >= ?', @start_date).with_results.each do |vote|
          vote.vote_results.each do |result|
            yield vote, result if result.rebel?
          end
        end
      end

      def send_tweet(msg)
        client.update msg
      end

      def client
        @client ||= Twitter::REST::Client.new do |config|
          config.consumer_key        = ENV.fetch('TWITTER_PP_CONSUMER_KEY')
          config.consumer_secret     = ENV.fetch('TWITTER_PP_CONSUMER_SECRET')
          config.access_token        = ENV.fetch('TWITTER_PP_ACCESS_TOKEN')
          config.access_token_secret = ENV.fetch('TWITTER_PP_ACCESS_TOKEN_SECRET')
        end
      end

      def helpers
        @helpers ||= Rails.application.routes.url_helpers
      end
    end
  end
end
