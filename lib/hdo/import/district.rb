module Hdo
  module Import
    class District < Type
      FIELDS = [
        Import.external_id_field,
        Field.new(:name, true, :string, 'The name of the electoral district.'),
      ]

      DESC = 'an electoral district'
      XML_EXAMPLE = <<-XML
<district>
  <externalId>Db</externalId>
  <name>Duckburg</name>
</district>
      XML

      def self.import(doc)
        doc.css("district").map do |district|
          p = ::District.find_or_create_by_external_id district.css("externalId").text
          p.update_attributes! :name => district.css("name").text

          print "."
        end
      end

    end
  end
end
