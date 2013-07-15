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

      def stats
        data = {}

        like_counts_for(issue_urls + question_urls).each do |entry|
          url      = entry['url']
          likes    = entry['total_count']
          type, id = url.match(%r[(issues|questions)/(\d+)]).captures

          if likes > 0
            data["facebook.likes.#{type}.#{id}"] = likes
          end
        end

        data['facebook.likes.holderdeord']         = org_info['likes']
        data['facebook.talking_about.holderdeord'] = org_info['talking_about_count']

        data
      end

      def send_to_graphite
        stats.each { |k, v| @graphite.add k, v }
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
        @hdo ||= fetch_path('/holderdeord?fields=talking_about_count,likes')
      end

      def fetch_path(path)
        retries = 0

        begin
          resp = Typhoeus.get "http://graph.facebook.com#{path}"

          if resp.code == 200
            JSON.parse(resp.body)
          else
            raise "bad graph API response for #{path.inspect}: #{resp.code} #{resp.body}"
          end
        rescue
          if retires < 3
            retries += 1
            sleep 1
            retry
          else
            raise
          end
        end
      end
    end

  end
end