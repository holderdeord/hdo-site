require 'socket'

module Hdo
  module Utils
    class FacebookStats

      DEFAULT_HOST     = 'www.holderdeord.no'
      DEFAULT_GRAPHITE = 'ops1.holderdeord.no:2003'

      def initialize(opts = {})
        @host  = opts[:host] || DEFAULT_HOST
        @debug = !!opts[:debug]

        ghost, gport   = (opts[:graphite] || DEFAULT_GRAPHITE).split(":")

        @graphite_host = ghost
        @graphite_port = Integer(gport)
      end

      def display
        counts = like_counts_for(issue_urls) + like_counts_for(question_urls)

        counts.sort_by { |e| e['total_count'] }.each do |e|
          if e['total_count'] > 0
            puts [e['total_count'].to_s.ljust(3), e['url']].join
          end
        end
      end

      def send_to_graphite
        ts = Time.now.to_i

        with_graphite_io do |io|
          record_likes(io, issue_urls, "issues", ts)
          record_likes(io, question_urls, "questions", ts)

          hdo = org_info

          io.puts "facebook.likes.holderdeord #{hdo['likes']} #{ts}"
          io.puts "facebook.talking_about.holderdeord #{hdo['talking_about_count']} #{ts}"
        end
      end

      private

      def record_likes(io, urls, type, ts)
        like_counts_for(urls).each do |entry|
          url   = entry['url']
          likes = entry['total_count']
          id    = url[%r[#{type}/(\d+)], 1]

          if likes > 0
            io.puts "facebook.likes.#{type}.#{id} #{likes} #{ts}"
          end
        end
      end

      def with_graphite_io(&blk)
        if @debug
          yield STDOUT
        else
          Socket.tcp(@graphite_host, @graphite_port) do |io|
            io.sync = true
            yield io
          end
        end
      end

      def helpers
        @helpers ||= Rails.application.routes.url_helpers
      end

      def issue_urls
        @issue_urls ||= Issue.published.map { |issue| helpers.issue_url(issue, host: @host) }
      end

      def question_urls
        @question_urls ||= Question.approved.map { |question| helpers.question_url(question, host: @host) }
      end

      def like_counts_for(urls)
        urls.each_slice(10).flat_map { |urls_slice| _like_counts_for(urls_slice) }.sort_by { |e| e['total_count'] }
      end

      def _like_counts_for(urls)
        fql = 'SELECT url, total_count FROM link_stat WHERE url in (%s)'
        fql = fql  % urls.map(&:inspect).join(',')

        data = fetch_path("/fql?q=#{URI.escape fql}").fetch('data')
        data.sort_by { |e| e[''] }
      end

      def org_info
        @hdo ||= fetch_path('/?ids=holderdeord').fetch('holderdeord')
      end

      def fetch_path(path)
        resp = Typhoeus.get "http://graph.facebook.com#{path}"

        if resp.code == 200
          JSON.parse(resp.body)
        else
          raise "bad graph API response for #{path.inspect}: #{resp.code} #{resp.body}"
        end
      end
    end

  end
end