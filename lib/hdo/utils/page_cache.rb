module Hdo
  module Utils
    class PageCache
      include Rails.application.routes.url_helpers

      def default_url_options
        @default_url_options ||= {host: 'localhost:3000'}.merge(Rails.application.config.action_mailer.default_url_options)
      end

      def self.dummy
        new Purger.new
      end

      def self.fastly
        new FastlyPurger.new
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
        end

        Representative.all.map do |r|
          @purger.add representative_url(r)
        end

        @purger.execute
      end

      def expire_question(question)
        # TODO: expire_question
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
        def execute
          Thread.new(@urls) { |urls| purge(urls) }
          @urls = []
        end

        private

        def purge(urls)
          hydra = Typhoeus::Hydra.new(max_concurrency: 50)

          urls.each do |url|
            Rails.logger.info "#{self.class}: queuing purge of #{url}"
            hydra.queue request_for(url)
          end

          hydra.run
        end

        def request_for(url)
          request = Typhoeus::Request.new(url, method: :purge)

          request.on_complete do |response|
            if response.success?
              Rails.logger.info "#{self.class}: purged #{request.url}: #{response.code}"
            else
              Rails.logger.error "#{self.class}: error purging #{request.url}: #{response.code} - #{response.return_message}"
            end
          end

          request
        end
      end

    end
  end
end