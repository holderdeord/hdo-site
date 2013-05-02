module Hdo
  module Utils
    class PageCache
      include Rails.application.routes.url_helpers

      def default_url_options
        @default_url_options ||= {host: 'localhost:3000'}.merge(Rails.application.config.action_mailer.default_url_options)
      end

      def self.dummy
        new(Purger.new)
      end

      def self.fastly(client)
        new(FastlyPurger.new(client))
      end

      def initialize(purger)
        @purger = purger
      end

      def expire_issue(issue)
        @purger.add issues_url
        @purger.add issue_url issue
        @purger.add votes_issue_url issue

        Party.all.map do |pr|
          @purger.add party_url(pr)
          @purger.add positions_party_url(pr)
        end

        Representative.all.map do |r|
          @purger.add representative_url(r)
        end

        @purger.execute
      end

      class Purger
        attr_reader :urls

        def initialize
          @urls = []
        end

        def add(url)
          @urls << url
        end

        def execute
          Rails.logger.info "#{self.class} would have purged: #{@urls.inspect}"
          @urls = []
        end
      end

      class FastlyPurger < Purger
        def initialize(client)
          @client = client
          super()
        end

        def execute
          Thread.new(@urls) { |urls| purge(urls) }
          @urls = []
        end

        private

        def purge(urls)
          urls.each do |url|
            Rails.logger.info "#{self.class}: purging #{url}"

            begin
              @client.purge url
            rescue => ex
              Rails.logger.error "#{self.class}: #{ex.message}"
            end
          end
        end
      end

    end
  end
end