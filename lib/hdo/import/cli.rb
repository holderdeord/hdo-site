module Hdo
  module Import
    class Cli

      def initialize(argv)
        if argv.empty?
          raise ArgumentError, 'no file given'
        end

        @files = argv
      end

      def run
        @files.each do |file|
          print "\nimporting #{file.inspect}:"
          doc = Nokogiri.XML(File.read(file)).first_element_child

          if doc
            import doc
          else
            p file => File.read(file)
            raise
          end
        end
      end

      private

      def import(doc)
        puts " #{doc.name}"

        case doc.name
        when 'representatives'
          Representative.import doc
        when 'parties'
          Party.import doc
        when 'committees'
          Committee.import doc
        when 'categories'
          Category.import doc
        when 'districts'
          District.import doc
        when 'issues'
          Issue.import doc
        when 'votes'
          Vote.import doc
        when 'promises'
          Promise.import doc
        else
          raise "unknown type: #{doc.name}"
        end
      end

    end
  end
end
