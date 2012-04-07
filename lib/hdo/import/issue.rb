module Hdo
  module Import
    class Issue
      FIELDS = [
        Import.external_id_field,
        Field.new(:summary,       true, :string, 'A (preferably one-line) summary of the issue.'),
        Field.new(:description,   true, :string, 'A longer description of the issue.'),
        Field.new(:issueType,     true, :string, 'The type of issue.'),
        Field.new(:lastUpdate,    true, :string, 'The time the issue was last updated in the parliament.'),
        Field.new(:reference,     true, :string, 'A reference. (...)'),
        Field.new(:documentGroup, true, :string, 'What document group this issue belongs to.')
      ]

      DESC = 'a parliament issue'
      XML_EXAMPLE = <<-XML
<issue>
  <externalId>1</externalId>
  <documentGroup>proposition</documentGroup>
  <issueType>regular-issue</issueType>
  <lastUpdate>2012-02-17T00:00:00+01:00</lastUpdate>
  <reference>Prop. 63 S (2011-2012)</reference>
  <summary>Samtykke til ratifikasjon av en frihandelsavtale og en avtale om arbeidstakerrettigheter.</summary>
  <description>Samtykke til ratifikasjon av en frihandelsavtale og en avtale om arbeidstakerrettigheter mellom EFTA-statene og Hongkong SAR.</description>
</issue>
      XML

    end
  end
end
