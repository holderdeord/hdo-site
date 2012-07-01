# encoding: utf-8

module Hdo
  module Import
    class Promise < Type
      FIELDS = [
        Field.new(:party, true, :string, 'The external id of the party.'),
        Field.new(:general, true, :boolean, "Whether this is considered a general promise (i.e. can be ambigious whether it has been fulfilled)."),
        Field.new(:categories, true, :list, "List of category names (matching names imported in <a href='#input-format-category'>&lt;category&gt;</a>)"),
        Field.new(:source, true, :string, "The source of the promise. (TODO: this should always be a URL)"),
        Field.new(:body, true, :string, "The body text of the promise."),
      ]

      DESC = 'a party promise'
      XML_EXAMPLE = <<XML
<promise>
  <party>H</party>
  <general>true</general>
  <categories>
    <category>GRUNNSKOLE</category>
  </categories>
  <source>PP:8</source>
  <body>Stille strengere krav til orden og oppførsel for å hindre at uro ødelegger undervisningen.</body>
</promise>
XML

      def self.import(doc)
        doc.css("promise").each do |promise|
          party      = ::Party.find_by_external_id!(promise.css("party").first.text.strip)
          general    = promise.css("general").first.text == "true"
          categories = ::Category.where(name: promise.css("categories category").map { |e| e.text })
          source     = promise.css("source").first.text
          body       = promise.css("body").first.text

          begin
            ::Promise.create!(
              party: party,
              general: general,
              categories: categories,
              source: source,
              body: body
            )

            print "."
          rescue ActiveRecord::RecordInvalid => ex
            STDERR.puts "failed to import promise: #{ex.message} for #{party.name}, #{body.inspect}"
          end
        end
      end

    end
  end
end
