require 'spec_helper'

describe Proposition do
  before do
    @start = 1.month.ago
    @finish = 1.month.from_now

    @parliament_session = ParliamentSession.make!(start_date: @start, end_date: @finish)
  end

  it 'has a valid blueprint' do
    Proposition.make.should be_valid
  end

  it 'is invalid without a body' do
    Proposition.make(body: nil).should_not be_valid
  end

  it 'is invalid without a unique external id' do
    invalid = Proposition.make

    invalid.external_id = Proposition.make!(:with_vote).external_id
    invalid.should_not be_valid
  end

  it "can have a large body" do
    body = "a" * 150_000

    prop = Proposition.make(:with_vote, body: body, description: "a")
    prop.save!

    prop.body.should == body
  end

  it '#plain_body removes HTML' do
    plain = Proposition.make(body: "<p>foo</p>").plain_body
    plain.should == 'foo'
  end

  it 'has a default pending status' do
    prop = Proposition.new
    prop.status.should == 'pending'
    prop.should be_pending
  end

  it 'can have "published" status' do
    prop = Proposition.make(status: 'published', simple_description: 'foo')
    prop.status.should == 'published'
    prop.should be_published
  end

  it 'can not have "published" status without a simple description' do
    prop = Proposition.make(status: 'published')
    prop.should_not be_valid

    prop.simple_description = 'foo'
    prop.should be_valid
  end

  it 'validates status' do
    Proposition.make(status: 'foo').should_not be_valid
  end

  it 'has a parliament session' do
    prop = Proposition.make(votes: [Vote.make(time: Time.now)])

    prop.parliament_session.should == @parliament_session
    prop.parliament_session_name.should == "#{@start.year}-#{@finish.year}"
  end

  it 'has a published scope' do
    published = Proposition.make!(status: 'published', simple_description: 'foo')
    _         = Proposition.make!(status: 'pending')

    Proposition.published.should == [published]
  end

  it 'can not have an empty simple description or body' do
    Proposition.make(simple_description: '').should_not be_valid
    Proposition.make(simple_body: '').should_not be_valid
  end

  it 'can add proposers' do
    proposers   = [Party.make!, Representative.make!]
    proposition = Proposition.make!

    proposers.each { |proposer| proposition.add_proposer(proposer) }
    proposition.reload.proposers.should == proposers
  end

  it 'finds the previous and next proposition by vote time' do
    v1 = Vote.make!(time: 1.month.ago)
    v2 = Vote.make!(time: Time.now)
    v3 = Vote.make!(time: 1.month.from_now)

    p1 = Proposition.make!(:votes => [v1])
    p2 = Proposition.make!(:votes => [v2])
    p3 = Proposition.make!(:votes => [v3])

    p1.next.should == p2
    p2.next.should == p3
    p3.next.should be_nil

    p1.previous.should be_nil
    p2.previous.should == p1
    p3.previous.should == p2
  end

  it 'does a source guess' do
    prop = Proposition.make(on_behalf_of: "Party", description: "Proposition from John Doe")
    Hdo::Utils::PropositionSourceGuesser.should_receive(:parties_for).with("#{prop.on_behalf_of} #{prop.description}")

    prop.source_guess
  end

  it 'is interesting by default' do
    proposition = Proposition.make
    proposition.should be_interesting

    proposition.interesting = false
    proposition.should_not be_interesting
  end

  it 'collects parliament issue data (for indexing)' do
    vote = Vote.make!
    i1 = ParliamentIssue.make!(votes: [vote], document_group: 'Foo')
    i2 = ParliamentIssue.make!(votes: [vote], document_group: nil, issue_type: 'Bar')

    prop = Proposition.make!(votes: [vote])
    prop.parliament_issue_document_group_names.should == ['Foo']
    prop.parliament_issue_type_names.should == ['Bar']
  end

  context "auto title" do
    def auto_title_for(str)
      Proposition.make(body: str).auto_title
    end

    it 'handles "Stortinget ber regjeringen"' do
      auto_title_for(
        "Stortinget ber regjeringen legge fram forslag."
      ).should == "Legge fram forslag."
    end

    it 'handles "Stortinget ber Regjeringen"' do
      auto_title_for(
        "Stortinget ber Regjeringen legge fram forslag."
      ).should == "Legge fram forslag."
    end

    it 'handles "Stortinget ber regjeringa"' do
      auto_title_for(
        "Stortinget ber regjeringa legge fram forslag."
      ).should == "Legge fram forslag."
    end

    it 'handles "Stortinget anmoder Stortingets presidentskap om å"' do
      auto_title_for(
        "Stortinget anmoder Stortingets presidentskap om å legge fram forslag."
      ).should == "Legge fram forslag."
    end

    it 'handles "vedlegges protokollen"' do
      auto_title_for(
        "Dokument 8:55 S (2013–2014) – representantforslag fra stortingsrepresentantene Eva Kristin Hansen, Trond Giske og Dag Terje Andersen om å tillate bruk av blyhagl utenfor våtmarksområder og skytebaner – vedlegges protokollen."
      ).should == "Legge representantforslag fra stortingsrepresentantene Eva Kristin Hansen, Trond Giske og Dag Terje Andersen om å tillate bruk av blyhagl utenfor våtmarksområder og skytebaner ved protokollen."
    end

    it 'handles "vedlegges protokollen" with newlines' do
      auto_title_for(
        "Dokument 8:139 S (2010–2011) – representantforslag\nfra stortingsrepresentantene Trine Skei Grande og Borghild Tenden\nom å nedsette et offentlig utvalg som skal følge opp Ansvarsreformen\nfor å bedre livssituasjonen til psykisk utviklingshemmede – vedlegges\nprotokollen."
      ).should == "Legge representantforslag fra stortingsrepresentantene Trine Skei Grande og Borghild Tenden om å nedsette et offentlig utvalg som skal følge opp Ansvarsreformen for å bedre livssituasjonen til psykisk utviklingshemmede ved protokollen."
    end


    it 'handles "vedlegges protokollen" with long dash delimiters' do
      auto_title_for(
        "Meld. St. 6 (2012–2013) – om en helhetlig integreringspolitikk – mangfold og fellesskap – vedlegges protokollen."
      )
    end

    it "handles middle name shorthand" do
      auto_title_for(
        "Dokument 12:30 (2011–2012) – grunnlovsforslag fra Per-Kristian Foss, Martin Kolberg, Marit Nybakk, Jette F. Christensen, Anders Anundsen, Hallgeir H. Langeland, Per Olaf Lundteigen, Geir Jørgen Bekkevold og Trine Skei Grande, romertall XXIV (domstolenes prøvingsrett), samtlige alternativer – bifalles ikke."
      ).should == "Ikke bifalle grunnlovsforslag fra Per-Kristian Foss, Martin Kolberg, Marit Nybakk, Jette F. Christensen, Anders Anundsen, Hallgeir H. Langeland, Per Olaf Lundteigen, Geir Jørgen Bekkevold og Trine Skei Grande, romertall XXIV (domstolenes prøvingsrett), samtlige alternativer."
    end

    it 'handles "vert vedlagt protokollen"' do
      auto_title_for(
        "Dokument 8:25 S (2012–2013) – Innstilling frå finanskomiteen om representantforslag fra stortingsrepresentantene Ketil Solvik-Olsen, Christian Tybring-Gjedde, Anders Anundsen, Kenneth Svendsen og Jørund Rytman om bedret saksgang ved skatteklager – vert vedlagt protokollen."
      ).should == "Legge innstilling frå finanskomiteen om representantforslag fra stortingsrepresentantene Ketil Solvik-Olsen, Christian Tybring-Gjedde, Anders Anundsen, Kenneth Svendsen og Jørund Rytman om bedret saksgang ved skatteklager ved protokollen."
    end

    it 'removes quote marks' do
      auto_title_for(
        "«Stortinget ber regjeringen fremme forslag til et revidert takstsystem for fastlegeordningen som belønner tidsbruk for behandling og oppfølging på laveste nivå (primærhelsetjenesten).»"
      ).should == "Fremme forslag til et revidert takstsystem for fastlegeordningen som belønner tidsbruk for behandling og oppfølging på laveste nivå (primærhelsetjenesten)."
    end
  end
end
