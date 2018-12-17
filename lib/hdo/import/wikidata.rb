require 'json'
require 'hashie/mash'
require 'logger'

module Hdo
  module Import
    class Wikidata
      attr_reader :log

      def initialize(opts = {})
        @api_key = opts[:api_key]
        @log = opts[:log] || Logger.new(STDOUT)
      end

      def decompose(representative)
        # TODO: fetch decompose claims
        data = JSON.parse(Typhoeus.get(representative.wikidata_url).body)
      end

      def data
        @data ||= (
          res = Typhoeus.get(
            "https://api.morph.io/everypolitician-scrapers/norway-stortingsrepresentanter-wikidata/data.json?key=#{@api_key}&query=select%20*%20from%20data"
          )

          if res.success?
            JSON.parse(res.body).map { |e| Hashie::Mash.new(e) }.group_by do |e|
              n = e.name || e.name__nb || e.original_wikiname
              n.split(' ').last if n
            end
          else
            raise "unable to fetch wikidata representatives: #{res.code} #{res.body}"
          end
        )
      end

      def import
        Representative.all.each do |representative|
          match = find_match(representative) || next

          if match.twitter
            if match.twitter != representative.twitter_id
              log.warn "wikidata: twitter mismatch - #{match.twitter} vs #{representative.twitter_id}"
            elsif representative.twitter_id.nil?
              log.warn "adding twitter id #{match.twitter.inspect} for #{representative.name}"
              representative.twitter_id = match.twitter
            end
          end

          representative.wikidata_id = match.id
          representative.save!
        end
      end

      def find_match(representative)
        candidates = data[representative.last_name] || []

        candidates.select! do |e|
          e['birth_date'].nil? || e['birth_date'] == representative.date_of_birth.localtime.strftime("%Y-%m-%d")
        end

        case candidates.size
        when 0
          log.error "no wikidata for #{representative.name}"
          nil
        when 1
          log.info "found: #{representative.name} => #{candidates.first.id}"
          candidates.first
        else
          hits = candidates.select { |e| e.name == representative.name }
          if hits.size > 1
            log.error "multiple candidates for #{representative.name}: #{hits.inspect}"
            nil
          else
            hits.first
          end
        end
      end

    end
  end
end