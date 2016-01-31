require 'typhoeus'
require 'nokogiri'

module Hdo
  module Utils
    class BlogFetcher
      def self.posts
        @instance ||= new
        @instance.posts
      end

      def self.last(count = 1)
        @last_result = Rails.cache.fetch("blog/latest/#{count}", expires_in: 5.minutes) { posts.first(count) }
      rescue => ex
        Rails.logger.error "#{self.class}: #{ex.message}"
        @last_result || [] # serve stale on exception
      end

      def initialize
        @posts = []
      end

      def posts
        @posts = extract_posts(fetch)
      end

      def url
        URI.join(AppConfig.blog_url, 'atom.xml')
      end

      private

      def fetch
        response = Typhoeus.get(url)

        if response.success?
          Nokogiri.XML(response.body)
        else
          raise "error #{response.code} fetching blog feed: #{response.body}"
        end
      end

      def extract_posts(feed)
        feed.css('entry').map { |e| Post.new(e) }
      end

      class Post
        attr_reader :title, :url, :updated_at, :author, :summary, :image

        def initialize(entry)
          @title      = entry.css('title').text
          @url        = entry.css('link[rel=alternate][type="text/html"]').first.try(:attr, 'href')
          @author     = entry.css('author').map { |e| e.css('name').text }.to_sentence
          @updated_at = Time.parse(entry.css('updated').text)
          @summary    = entry.css('summary').text
          @image      = entry.css('link[rel=thumbnail][type="image/jpg"], link[rel=thumbnail][type="image/png"]').first.try(:attr, 'href')
        end

        alias_method :teaser, :summary

      end

    end
  end
end
