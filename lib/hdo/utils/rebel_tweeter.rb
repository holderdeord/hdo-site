# -*- coding: utf-8 -*-

module Hdo
  module Utils
    class RebelTweeter
      include Enumerable

      MIN_TWEET_INTERVAL = 60
      MAX_TWEET_LENGTH   = 140

      MESSAGES = [
        "%{party}s %{representative} brøt med partiflertallet og stemte %{result} følgende forslag:",
        "%{party}s %{representative} stemte mot eget parti i følgende forslag:",
        "%{party}s %{representative} stemte ikke sammen med resten av stortingsgruppa i følgende forslag:"
      ]

      def self.since(date)
        new(date)
      end

      def initialize(start_date)
        @start_date = start_date
      end

      def each(&blk)
        each_rebel_vote do |vote, vote_result|
          yield message_for(vote, vote_result)
        end
      end

      def votes
        res = []

        each_rebel_vote do |vote, vote_result|
          res << [vote, vote_result]
        end

        res
      end

      def print
        each_rebel_vote do |vote, vote_result|
          msg = message_for(vote, vote_result)
          puts "#{msg} (#{msg.size})"
        end
      end

      def tweet
        each_rebel_vote do |vote, vote_result|
          send_tweet message_for(vote, vote_result)
          sleep interval
        end
      end

      private

      def interval
        MIN_TWEET_INTERVAL + rand(MIN_TWEET_INTERVAL)
      end

      def external_url(vote)
        id = vote.parliament_issues.last.external_id

        "https://stortinget.no/no/Saker-og-publikasjoner/Saker/Sak/Voteringsoversikt/?p=#{id}"
      rescue
        helpers.vote_url(vote, host: 'data.holderdeord.no', src: 'rtw')
      end

      def message_for(vote, vote_result)
        representative = vote_result.representative
        name           = representative.has_twitter? ? "@#{representative.twitter_id}" : representative.name
        party          = representative.party_at(vote.time)
        message        = MESSAGES.sample % {party: party.short_name, representative: name, result: vote_result.human.downcase}
        url            = external_url(vote)

        [message.truncate(MAX_TWEET_LENGTH - url.length - 1), url].join(' ')
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
      rescue Twitter::Error => ex
        # don't crash - we'll keep trying the rest our tweets
        Rails.logger.error ex.message
        puts ex.message
      end

      def client
        @client ||= Hdo::Utils::TwitterClients.partipisken
      end

      def helpers
        @helpers ||= Rails.application.routes.url_helpers
      end
    end
  end
end
