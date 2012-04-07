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
          puts "importing #{file.inspect}"
          doc = Nokogiri.XML(File.read(file)).first_element_child
          import doc
        end
      end

      private

      def import(doc)
        case doc.name
        when 'representatives'
          Representative.import doc
        when 'parties'
          Party.import doc
        when 'committees'
          Committee.import doc
        else
          raise "uknown type: #{doc.name}"
        end
      end

    end
  end
end
