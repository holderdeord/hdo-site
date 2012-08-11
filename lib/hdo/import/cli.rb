require 'optparse'
require 'set'

module Hdo
  module Import
    class CLI

      def initialize(argv)
        if argv.empty?
          raise ArgumentError, 'no args'
        else
          @options = parse_options argv
          @cmd     = argv.shift
          @rest    = argv
        end
      end

      def run
        case @cmd
        when 'json'
          import_files
        when 'daily'
          raise NotImplementedError
        when 'api'
          import_api
        when 'dev'
          import_api(30)
        when 'representatives'
          import_api_representatives
        when 'votes'
          import_api_votes
        else
          raise ArgumentError, "unknown command: #{@cmd.inspect}"
        end
      end

      private

      def import_api(vote_limit = nil)
        persister.import_parties parsing_data_source.parties
        persister.import_committees parsing_data_source.committees
        persister.import_districts parsing_data_source.districts
        persister.import_categories parsing_data_source.categories

        import_api_representatives
        import_api_votes(vote_limit)
      end

      def import_api_representatives
        persister.import_representatives parsing_data_source.representatives
        persister.import_representatives parsing_data_source.representatives_today
      end

      def import_api_votes(vote_limit = nil)
        issues = parsing_data_source.issues

        persister.import_issues issues
        persister.import_votes votes_for(parsing_data_source, issues, vote_limit)
      end

      def votes_for(data_source, issues, limit = nil)
        result = Set.new

        issues.each do |issue|
          result += data_source.votes_for(issue.external_id)
          break if limit && result.size >= limit
        end

        result.to_a
      end

      def import_files
        @rest.each do |file|
          print "\nimporting #{file}:"

          str = file == "-" ? STDIN.read : File.read(file)
          data = MultiJson.decode(str)

          data = case data
                 when Array
                   data
                 when Hash
                   [data]
                 else
                   raise TypeError, "expected Hash or Array, got: #{data.inspect}"
                 end

          import_data data
        end
      end

      def import_data(data)
        kinds = data.group_by do |hash|
          hash['kind'] or raise ArgumentError, "missing 'kind' property: #{hash.inspect}"
        end

        kinds.each do |kind, hashes|
          case kind
          when 'hdo#representative'
            persister.import_representatives hashes.map { |e| StortingImporter::Representative.from_hash(e) }
          when 'hdo#party'
            persister.import_parties hashes.map { |e| StortingImporter::Party.from_hash(e) }
          when 'hdo#committee'
            persister.import_committees hashes.map { |e| StortingImporter::Committee.from_hash(e) }
          when 'hdo#category'
            persister.import_categories hashes.map { |e| StortingImporter::Categories.from_hash(e) }
          when 'hdo#district'
            persister.import_districts hashes.map { |e| StortingImporter::District.from_hash(e) }
          when 'hdo#issue'
            persister.import_issues hashes.map { |e| StortingImporter::Issue.from_hash(e) }
          when 'hdo#vote'
            # import_votes (plural) will also run VoteInferrer.
            persister.import_votes hashes.map { |e| StortingImporter::Vote.from_hash(e) }
          when 'hdo#promise'
            persister.import_promises hashes.map { |e| StortingImporter::Promise.from_hash(e) }
          else
            raise "unknown type: #{kind}"
          end
        end
      end

      def parsing_data_source
        @parsing_data_source ||= (
          ds = Hdo::StortingImporter::ParsingDataSource.new(api_data_source)

          case @options[:cache]
          when 'rails'
            Hdo::StortingImporter::CachingDataSource.new(ds, Rails.cache)
          when true
            Hdo::StortingImporter::CachingDataSource.new(ds)
          else
            ds
          end
        )
      end

      def api_data_source
        @api_data_source ||= Hdo::StortingImporter::ApiDataSource.default
      end

      def persister
        @persister ||= (
          persister = Persister.new
          persister.log = log

          persister
        )
      end

      def log
        @log ||= (
          if @options[:quiet]
            Logger.new(File::NULL)
          else
            Hdo::StortingImporter.logger
          end
        )
      end

      def parse_options(args)
        options = {}

        OptionParser.new { |opt|
          opt.on("-s", "--quiet") { @options[:quiet] = true }
          opt.on("--cache [rails]", "Cache results of API calls. Defaults to caching in memory, pass 'rails' to use Rails.cache instead.") do |arg|
            options[:cache] = arg || true
          end

          opt.on("-h", "--help") do
            puts opt
            exit 1
          end
        }.parse!(args)

        options[:cache] = ENV['CACHE']

        options
      end

    end # CLI
  end # Import
end # Hdo