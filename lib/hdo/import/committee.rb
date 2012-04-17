module Hdo
  module Import
    class Committee < Type
      FIELDS = [
        Import.external_id_field,
        Field.new(:name, true, :string, 'The name of the topic.'),
      ]

      DESC = 'a parliamentary committe'
      XML_EXAMPLE = <<-XML
<committee>
  <externalId>ARBSOS</externalId>
  <name>Arbeids- og sosialkomiteen</name>
</committee>
      XML

      def self.import(doc)
        doc.css("committee").each do |party|
          p = ::Committee.find_or_create_by_external_id party.css("externalId").text
          p.update_attributes! :name => party.css("name").text

          print "."
        end
      end
    end
  end
end
