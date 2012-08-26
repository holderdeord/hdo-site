require 'optparse'
require 'set'
require 'open-uri'

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
        when 'promises'
          import_promises
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

      def import_promises
        spreadsheet = @rest.first or raise "no spreadsheet path given"

        promises = Hdo::StortingImporter::Promise.from_xlsx(spreadsheet)
        persister.import_promises promises
      end

      def import_api_votes(vote_limit = nil)
        parliament_issues = parsing_data_source.parliament_issues

        if @options[:parliament_issue_ids]
          issues = issues.select { |i| @options[:parliament_issue_ids].include? i.external_id }
        end

        persister.import_parliament_issues parliament_issues

        each_vote_for(parsing_data_source, parliament_issues, vote_limit) do |votes|
          persister.import_votes votes, infer: false
        end

        persister.infer_all_votes
      end

      def each_vote_for(data_source, parliament_issues, limit = nil)
        count = 0

        parliament_issues.each_with_index do |parliament_issue, index|
          votes = data_source.votes_for(parliament_issue.external_id)
          count += votes.size

          yield votes
          break if limit && count >= limit

          parliament_issue_count = index + 1
          remaining_parliament_issues = parliament_issues.size - parliament_issue_count
          remaining_votes = (count / parliament_issue_count.to_f) * remaining_parliament_issues

          @log.info "->        #{count} votes for #{parliament_issue_count} parliament issues imported"
          @log.info "->        about #{remaining_votes.to_i} votes remaining for #{remaining_parliament_issues} parliament issues"
        end
      end

      def import_files
        @rest.each do |file|
          print "\nimporting #{file}:"

          if file == "-"
            str = STDIN.read
          else
            str = open(file) { |io| io.read }
          end

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
            persister.import_parliament_issues hashes.map { |e| StortingImporter::ParliamentIssue.from_hash(e) }
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

          opt.on("--parliament-issues ISSUE_IDS", "Only import this comma-sparated list of issue external ids") do |ids|
            options[:parliament_issue_ids] = ids.split(",")
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