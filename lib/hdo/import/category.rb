module Hdo
  module Import
    class Category < Type
      FIELDS = [
        Import.external_id_field,
        Field.new(:name, true, :string, 'The name of the category.'),
        Field.new(:subcategories, false, 'list<category>', 'A list of subcategories.'),
      ]

      DESC = 'a parliamentary category, used to categorize issues'
      XML_EXAMPLE = <<-XML
<category>
  <externalId>5</externalId>
  <name>EMPLOYMENT</name>
  <subcategories>
    <category>
      <externalId>6</externalId>
      <name>WAGES</name>
    </category>
  </subcategories>
</category>
      XML

      def self.import(doc)
        doc.xpath("./category").each do |category|
          external_id = category.css("externalId").first.text
          name        = category.css("name").first.text

          parent = ::Category.find_or_create_by_external_id external_id
          parent.name = name
          parent.main = true
          parent.save!

          category.css("subcategories > category").each do |subcategory|
            subcategory_external_id = subcategory.css("externalId").first.text
            subcategory_name = subcategory.css("name").first.text

            child = ::Category.find_or_create_by_external_id(subcategory_external_id)
            child.name = subcategory_name
            child.save!

            parent.children << child
          end

          print "."
        end
      end

    end
  end
end
