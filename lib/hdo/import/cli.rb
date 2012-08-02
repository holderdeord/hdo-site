require 'optparse'

module Hdo
  module Import
    class CLI

      def initialize(argv)
        if argv.empty?
          raise ArgumentError, 'no args'
        else
          @options = {}

          OptionParser.new { |opt|
            opt.on("-s", "--quiet") { @options[:quiet] = true }
            opt.on("-h", "--help") do
              puts opt
              exit 1
            end
          }.parse!(argv)

          @cmd = argv.shift
          @rest = argv
        end
      end

      def run
        case @cmd
        when 'xml'
          import_files
        when 'daily'
          raise NotImplementedError
        when 'api'
          import_api
        when 'dev'
          import_api(30)
        when 'representatives'
          import_api_representatives
        else
          raise ArgumentError, "unknown command: #{@cmd.inspect}"
        end
      end

      private

      def import_api(vote_limit = nil)
        persister.import_parties parsing_data_source.parties
        persister.import_committees parsing_data_source.committees
        persister.import_districts parsing_data_source.districts

        import_api_representatives

        persister.import_categories parsing_data_source.categories

        issues = parsing_data_source.issues

        persister.import_issues issues
        persister.import_votes votes_for(parsing_data_source, issues, vote_limit)
      end

      def import_api_representatives
        persister.import_representatives parsing_data_source.representatives
        persister.import_representatives parsing_data_source.representatives_today
      end

      def votes_for(data_source, issues, limit = nil)
        result = []

        issues.each do |issue|
          result += data_source.votes_for(issue.external_id)
          break if limit && result.size >= limit
        end

        result
      end

      def import_files
        @rest.each do |file|
          print "\nimporting #{file}:"

          str = file == "-" ? STDIN.read : File.read(file)
          doc = Nokogiri.XML(str)

          if doc
            import_doc doc
          else
            p file => str
            raise
          end
        end
      end

      def import_doc(doc)
        name = doc.first_element_child.name
        puts " #{name}"

        case name
        when 'representatives'
          persister.import_representatives StrortingImporter::Representative.from_hdo_doc(doc)
        when 'parties'
          persister.import_parties StortingImporter::Party.from_hdo_doc(doc)
        when 'committees'
          persister.import_committees StortingImporter::Committee.from_hdo_doc(doc)
        when 'categories'
          persister.import_categories StortingImporter::Categories.from_hdo_doc(doc)
        when 'districts'
          persister.import_districts StortingImporter::District.from_hdo_doc(doc)
        when 'issues'
          persister.import_issues StortingImporter::Issue.from_hdo_doc(doc)
        when 'votes'
          persister.import_votes StortingImporter::Vote.from_hdo_doc(doc)
        when 'promises'
          persister.import_promises StortingImporter::Promise.from_hdo_doc(doc)
        else
          raise "unknown type: #{name}"
        end
      end

      def parsing_data_source
        @parsing_data_source ||= Hdo::StortingImporter::ParsingDataSource.new(api_data_source)
      end

      def api_data_source
        @api_data_source ||= Hdo::StortingImporter::ApiDataSource.new("http://data.stortinget.no")
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

    end # CLI
  end # Import
end # Hdo