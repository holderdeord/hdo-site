require 'socket'

module Hdo
  module Utils
    class FacebookStats
      DEFAULT_HOST = 'www.holderdeord.no'

      def initialize(opts = {})
        @host     = opts[:host] || DEFAULT_HOST
        @graphite = opts[:graphite] || GraphiteReporter.new(debug: opts[:debug])
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
        like_counts_for(issue_urls + question_urls).each do |entry|
          url      = entry['url']
          likes    = entry['total_count']
          type, id = url.match(%r[(issues|questions)/(\d+)]).captures

          if likes > 0
            @graphite.add "facebook.likes.#{type}.#{id}", likes
          end
        end

        hdo = org_info

        @graphite.add 'facebook.likes.holderdeord', hdo['likes']
        @graphite.add 'facebook.talking_about.holderdeord', hdo['talking_about_count']

        @graphite.submit
      end

      private

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