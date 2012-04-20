# encoding: utf-8

module Hdo
  module Import
    class Promise < Type
      FIELDS = [
        Field.new(:party, true, :string, 'The external id of the party.'),
        Field.new(:general, true, :boolean, "Whether this is considered a general promise (i.e. can be ambigious whether it has been fulfilled)."),
        Field.new(:topics, true, :list, "List of topic names (matching names imported in <a href='#input-format-topic'>&lt;topic&gt;</a>)"),
        Field.new(:source, true, :string, "The source of the promise. (TODO: this should always be a URL)"),
        Field.new(:body, true, :string, "The body text of the promise."),
      ]

      DESC = 'a party promise'
      XML_EXAMPLE = <<XML
<promise>
  <party>H</party>
  <general>true</general>
  <topics>
    <topic>GRUNNSKOLE</topic>
  </topics>
  <source>PP:8</source>
  <body>Stille strengere krav til orden og oppførsel for å hindre at uro ødelegger undervisningen.</body>
</promise>
XML

      def self.import(doc)
        doc.css("promise").each do |promise|
          party   = ::Party.find_by_external_id!(promise.css("party").first.text)
          general = promise.css("general").first.text == "true"
          topics  = ::Topic.where(name: promise.css("topics topic").map { |e| e.text })
          source  = promise.css("source").first.text
          body    = promise.css("body").first.text

          ::Promise.create!(
            party: party,
            general: general,
            topics: topics,
            source: source,
            body: body
          )

          print "."
        end
      end

    end
  end
end
