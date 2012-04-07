module Hdo
  module Import
    class Topic
      FIELDS = [
        Import.external_id_field,
        Field.new(:name, true, :string, 'The name of the topic.'),
        Field.new(:subtopics, false, 'list<topic>', 'A list of subtopics.'),
      ]

      DESC = 'a parliamentary topic'
      XML_EXAMPLE = <<-XML
<topic>
  <externalId>5</externalId>
  <name>EMPLOYMENT</name>
  <subtopics>
    <topic>
      <externalId>6</externalId>
      <name>WAGES</name>
    </topic>
  </subtopics>
</topic>
      XML

      def self.import(doc)
        doc.xpath("./topic").each do |topic|
          external_id = topic.css("externalId").first.text
          name        = topic.css("name").first.text

          parent = ::Topic.find_or_create_by_external_id external_id
          parent.name = name
          parent.main = true
          parent.save!

          topic.css("subtopics > topic").each do |subtopic|
            subtopic_external_id = subtopic.css("externalId").first.text
            subtopic_name = subtopic.css("name").first.text

            child = ::Topic.find_or_create_by_external_id(subtopic_external_id)
            child.name = subtopic_name
            child.save!

            parent.children << child
          end
        end
      end

    end
  end
end
