module Hdo
  module Import
    class Vote
      FIELDS = [
        Import.external_id_field,
        Field.new(:externalIssueId, true, :string, "The id (matching the issue's externalId) of the issue being voted on."),
        Field.new(:counts, true, :element, "An element with <for>, <against> and <absent> counts (see example)."),
        Field.new(:enacted, true, :boolean, "Whether the proposal was enacted."),
        Field.new(:subject, true, :string, "The subject of the vote."),
        Field.new(:method, true, :string, "??"),
        Field.new(:resultType, true, :string, "??"),
        Field.new(:time, true, :string, "The timestamp for the vote."),
        Field.new(:representatives, true, :element, "An element with each representatives vote. The element should contain a set of <a href='#input-format-representative'>&gt;representative&lt;</a> elements with an extra subnode 'voteResult', where valid values are 'for', 'against', 'absent'. See example."),
      ]

      DESC = 'a parliamentary vote'
      XML_EXAMPLE = <<-XML
<vote>
  <externalId>1984</externalId>
  <externalIssueId>40702</externalIssueId>
  <counts>
    <for>88</for>
    <against>80</against>
    <absent>1</absent>
  </counts>
  <enacted>true</enacted>
  <subject>Romertall I.</subject>
  <method>ikke_spesifisert</method>
  <resultType>ikke_spesifisert</resultType>
  <time>2012-02-07T12:40:29.687</time>
  <representatives>
    <representative>
      <externalId>DD</externalId>
      <firstName>Donald</firstName>
      <lastName>Duck</lastName>
      <district>Duckburg</district>
      <party>Democratic Party</party>
      <committees>
        <committe>A</committe>
        <committe>B</committe>
      </committes>
      <period>2011-2012</period>
      <dateOfBirth>1969-04-04T00:00:00</dateOfBirth>
      <dateOfDeath>1969-04-04T00:00:00</dateOfDeath>
      <voteResult>against</voteResult>
    </representative>
</vote>
      XML

      def self.import(doc)
        doc.xpath("./vote").each { |vote_node| import_vote vote_node }
      end

      VOTE_RESULTS = {
        "for"     => 1,
        "absent"  => 0,
        "against" => -1
      }

      def self.import_vote(vote_node)
        vote = ::Vote.find_or_create_by_external_id vote_node.css("externalId").first.text
        issue = ::Issue.find_by_external_id! vote_node.css("externalIssueId").first.text

        vote.update_attributes!(
          :issue         => issue,
          :for_count     => Integer(vote_node.css("counts for").text),
          :against_count => Integer(vote_node.css("counts against").text),
          :absent_count  => Integer(vote_node.css("counts absent").text),
          :enacted       => vote_node.css("enacted").text == "true",
          :subject       => vote_node.css("subject").text,
          :time          => Time.parse(vote_node.css("time").text)
        )

        vote_node.css("representatives representative").each do |node|
          # assumes externalId is unique
          xid = node.css("externalId").text
          result_text = node.css("voteResult").text


          result = VOTE_RESULTS[result_text] or raise "invalid vote result: #{result_text.inspect}"
          rep = ::Representative.find_by_external_id(xid)

          unless rep
            # alternate representative - not part of the list
            rep = Representative.import_representative(node, true)
          end

          # TODO: validate save. need to support multiple issues per vote first.
          ::VoteResult.create(:representative => rep, :vote => vote, :result => result)
        end

        print "."
      end

    end
  end
end
