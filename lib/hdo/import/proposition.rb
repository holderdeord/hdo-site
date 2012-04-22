module Hdo
  module Import
    class Proposition < Type
      FIELDS = [
        Import.external_id_field,
        Field.new(:description, true, :string, 'A short description of the proposition.'),
        Field.new(:deliveredBy, true, :string, "The representative that delivered the proposition. The element should contain a <a href='#input-format-representative'>&lt;representative&gt;</a> element."),
        Field.new(:onBehalfOf, true, :string, "Description of who is behind the proposition."),
        Field.new(:body, true, :string, "The full text of the proposition."),
      ]

      DESC = 'a proposition being voted over'
      XML_EXAMPLE = <<-XML
<proposition>
  <externalId>1</externalId>
  <description>Proposition 1 on behalf of Democratic Party and Green Party</description>
  <deliveredBy>
#{indent Representative::XML_EXAMPLE, 4}
  </deliveredBy>
  <onBehalfOf>Democratic Party and Green Party</onBehalfOf>
  <body>Full text of the proposition.</body>
</proposition>
      XML

      def self.import(node)
        external_id  = node.css("externalId").first.text
        description  = node.css("description").first.text.strip
        on_behalf_of = node.css("onBehalfOf").first.text.strip
        body         = node.css("body").first.text.strip

        rep_node = node.css("deliveredBy representative").first
        if rep_node
          rep = Representative.from rep_node
        end

        prop = ::Proposition.find_or_create_by_external_id(external_id)

        attributes = {
          description: description,
          on_behalf_of: on_behalf_of,
          body: body
        }

        attributes[:representative_id] = rep.id if rep

        prop.update_attributes! attributes

        prop
      rescue
        puts node
        raise
      end

    end
  end
end
