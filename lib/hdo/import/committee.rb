module Hdo
  module Import
    class Committee
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

    end
  end
end
