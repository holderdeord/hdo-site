module Hdo
  module Import
    class Topic
      FIELDS = [
        Import.external_id_field,
        Field.new(:name, true, :string, 'The name of the topic.'),
      ]

      DESC = 'a parliamentary topic'
      XML_EXAMPLE = <<-XML
<topic>
  <externalId>5</externalId>
  <name>EMPLOYMENT</name>
</topic>
      XML

    end
  end
end
