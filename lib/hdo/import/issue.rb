module Hdo
  module Import
    class Issue < Type
      FIELDS = [
        Import.external_id_field,
        Field.new(:summary,       true,  :string, 'A (preferably one-line) summary of the issue.'),
        Field.new(:description,   true,  :string, 'A longer description of the issue.'),
        Field.new(:type,          true,  :string, 'The type of issue.'),
        Field.new(:status,        true,  :string, 'The status of the issue.'),
        Field.new(:lastUpdate,    true,  :string, 'The time the issue was last updated in the parliament.'),
        Field.new(:reference,     true,  :string, 'A reference.'),
        Field.new(:documentGroup, true,  :string, 'What document group this issue belongs to.'),
        Field.new(:committee,     false, :string, "What committee this issue belongs to. Should match the 'name' field in the committee type."),
        Field.new(:categories,    false, 'list',  "List of categories (matching the 'name' field of the category type).")
      ]

      DESC = 'a parliament issue'
      XML_EXAMPLE = <<-XML
<issue>
  <externalId>1</externalId>
  <documentGroup>proposition</documentGroup>
  <issueType>common</issueType>
  <status>received</status>
  <lastUpdate>2012-02-17T00:00:00+01:00</lastUpdate>
  <reference>Prop. 63 S (2011-2012)</reference>
  <summary>Samtykke til ratifikasjon av en frihandelsavtale og en avtale om arbeidstakerrettigheter.</summary>
  <description>Samtykke til ratifikasjon av en frihandelsavtale og en avtale om arbeidstakerrettigheter mellom EFTA-statene og Hongkong SAR.</description>
  <committee>Utenrikskomiteen</committee>
  <categories>
    <category>EFTA/EU</category>
  </categories>
</issue>
      XML

      def self.import(doc)
        doc.css("issue").each do |issue|
          external_id    = issue.css("externalId").first.text
          document_group = issue.css("documentGroup").first.text
          issue_type     = issue.css("type").first.text
          status         = issue.css("status").first.text
          last_update    = Time.parse issue.css("lastUpdate").first.text
          reference      = issue.css("reference").first.text
          summary        = issue.css("summary").first.text
          description    = issue.css("description").first.text

          committee_node = issue.css("committee").first
          if committee_node
            committee = ::Committee.find_by_name! committee_node.text
          else
            committee = nil
          end

          categories = issue.css("categories > category").map do |e|
            ::Category.find_by_name! e.text
          end

          issue = ::Issue.find_or_create_by_external_id external_id
          issue.update_attributes!(
            :document_group => document_group,
            :issue_type     => issue_type, # AR doesn't like :type as a column name
            :status         => status,
            :last_update    => last_update,
            :reference      => reference,
            :summary        => summary,
            :description    => description,
            :committee      => committee,
            :categories     => categories
          )

          print "."
        end
      end

    end
  end
end
