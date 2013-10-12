require 'spec_helper'

module Hdo
  module Import
    describe Persister do
      context 'representatives' do

        include_context :persister

        def setup_representative(rep)
          District.make!(:name => rep.district) unless District.find_by_name(rep.district)

          rep.parties.map do |p|
            Party.make!(:external_id => p.external_id) unless Party.find_by_external_id(p.external_id)
          end

          rep.committees.map do |c|
            Committee.make!(:external_id => c.external_id) unless Committee.find_by_external_id(c.external_id)
          end
        end

        it 'imports a representative' do
          example = StortingImporter::Representative.example
          setup_representative(example)

          persister.import_representative example

          Representative.count.should == 1

          rep = Representative.first
          rep.first_name.should == example.first_name
          rep.last_name.should == example.last_name
          rep.current_party.external_id.should == example.parties.first.external_id
          rep.committees.map { |e| e.external_id }.should == example.committees.map { |e| e.external_id }
        end

        it 'updates an existing representative based on external id' do
          example = StortingImporter::Representative.example
          setup_representative(example)

          persister.import_representative example

          Representative.count.should == 1

          update = StortingImporter::Representative.example('first_name' => 'changed-name')
          persister.import_representative update

          Representative.count.should == 1
          Representative.first.first_name.should == 'changed-name'
        end

        context 'committee memberships' do
          def membership_to_a(ms)
            [
              ms.committee.external_id,
              ms.start_date.strftime("%Y-%m-%d"),
              ms.end_date.try(:strftime, "%Y-%m-%d")
            ]
          end

          def import(*memberships)
            hashes = memberships.map do |e|
              raise ArgumentError, "expected 3 elements, got #{e.inspect}" unless e.size == 3
              {
                'kind'        => 'hdo#committee_membership',
                'external_id' => e[0],
                'start_date'  => e[1],
                'end_date'    => e[2]
              }
            end

            example = StortingImporter::Representative.example('committees' => hashes)
            setup_representative(example)

            persister.import_representative(example)
          end

          def representative
            Representative.count.should == 1
            Representative.first
          end

          def actual_memberships
            ms = representative.committee_memberships
            ms.sort_by { |e| e.start_date }.map { |e| membership_to_a(e) }
          end

          it 'adds current memberships' do
            import ['JUSTIS', '2008-01-01', nil],
                   ['ARBSOS', '2008-01-01', nil]

            actual_memberships.should == [
              ['JUSTIS', '2008-01-01', nil],
              ['ARBSOS', '2008-01-01', nil]
            ]
          end

          it 'closes current memberships if new ones are added' do
            import ['JUSTIS', '2008-01-01', nil],
                   ['UUFK', '2010-01-01', nil]

            import ['UUFK', '2010-01-01', nil]

            actual_memberships.should == [
              ['JUSTIS', '2008-01-01', (Date.today - 1).strftime("%Y-%m-%d")],
              ['UUFK', '2010-01-01', nil]
            ]
          end

          it 'does closes current memberships with the current date if there are no new ones' do
            import ['JUSTIS', "2013-04-19", nil]
            import # nothing

            actual_memberships.should == [
             ['JUSTIS', "2013-04-19", Date.today.strftime("%Y-%m-%d")]
            ]
          end

          it 'extends existing memberships' do
            import ['JUSTIS', '2008-01-01', nil]
            import ['JUSTIS', '2010-01-01', nil]

            actual_memberships.should == [
              ['JUSTIS', '2008-01-01', nil],
            ]
          end

          it "can leave a committee for a while" do
            Date.stub(today: Date.new(2010, 6, 2))

            import ['JUSTIS', '2008-01-01', nil]
            import ['ARBSOS', '2009-01-01', nil]

            actual_memberships.should == [
              ['JUSTIS', '2008-01-01', '2010-06-01'],
              ['ARBSOS', '2009-01-01', nil]
            ]

            Date.stub(today: Date.new(2011, 1, 1))

            import ['JUSTIS', '2011-01-01', nil],
                   ['ARBSOS', '2011-01-01', nil]

            actual_memberships.should == [
              ['JUSTIS', '2008-01-01', '2010-06-01'],
              ['ARBSOS', '2009-01-01', nil],
              ['JUSTIS', '2011-01-01', nil]
            ]
          end

          it 'does not accept start dates in the future' do
            start_date = 1.month.from_now.strftime("%Y-%m-%d")

            expect {
              import ['JUSTIS', start_date, nil]
            }.to raise_error(IncompatibleCommitteeMembershipError, "start date #{start_date} is in the future")
          end

          it 'can both close and extend' do
            import ['JUSTIS', '2008-01-01', nil],
                   ['UUFK', '2010-01-01', nil]

            import ['UUFK', '2008-01-01', nil]

            actual_memberships.should == [
              ['JUSTIS', '2008-01-01', (Date.today - 1).strftime("%Y-%m-%d")],
              ['UUFK', '2008-01-01', nil]
            ]
          end
        end

        context 'party membership' do
          def membership_to_a(ms)
            [
              ms.party.external_id,
              ms.start_date.strftime("%Y-%m-%d"),
              ms.end_date.try(:strftime, "%Y-%m-%d")
            ]
          end

          def import(*memberships)
            hashes = memberships.map do |e|
              raise ArgumentError, "expected 3 elements, got #{e.inspect}" unless e.size == 3
              {
                'kind'       => 'hdo#party_membership',
                'external_id' => e[0],
                'start_date'  => e[1],
                'end_date'    => e[2]
              }
            end

            example = StortingImporter::Representative.example('parties' => hashes, 'committees' => [])
            setup_representative(example)

            persister.import_representative(example)
          end

          def representative
            Representative.count.should == 1
            Representative.first
          end

          def actual_memberships
            ms = representative.party_memberships
            ms.sort_by { |e| e.start_date }.map { |e| membership_to_a(e) }
          end

          it 'extends a (continuous) party membership backwards in time' do
            import ['A', '2010-10-1', nil]
            import ['A', '2009-10-1','2010-9-30']

            actual_memberships.should == [
              ['A', '2009-10-01', nil]
            ]
          end

          it 'adds multiple party memberships' do
            import ['A',  '2008-10-01', '2009-01-01'],
                   ['SV', '2009-01-02', nil]


            actual_memberships.should == [
              ['A', '2008-10-01', '2009-01-01'],
              ['SV', '2009-01-02', nil]
            ]
          end

          it 'ignores party memberships which matches the current membership' do
            # identical entries
            import ['A', '2012-01-01', nil]
            import ['A', '2012-01-01', nil]

            # start_date included in existing membership, party matches - ignored
            import ['A', '2012-10-01', nil]

            actual_memberships.should == [
              ['A', '2012-01-01', nil]
            ]
          end

          it "moves the current membership's start_date to earlier date if there's no conflict" do
            import ['A', '2012-01-01', nil]
            import ['A', '2009-01-01', nil]

            actual_memberships.should == [
              ['A', '2009-01-01', nil]
            ]
          end

          it "does not move the current membership's start_date if party doesn't match" do
            import ['A', '2012-01-01', nil]

            expect {
              import ['SV', '2009-01-01', nil]
            }.to raise_error(IncompatiblePartyMembershipError)
          end

          it 'imports a full set of memberships' do
            import ['A', '2007-01-01', '2007-12-31'],
                   ['SV', '2008-01-01', '2008-12-31'],
                   ['A', '2009-01-01', nil]

            actual_memberships.should == [
              ['A', '2007-01-01', '2007-12-31'],
              ['SV', '2008-01-01', '2008-12-31'],
              ['A', '2009-01-01', nil]
            ]
          end

          it 'fails if any of the memberships are overlapping for different parties' do
            expect {
              import ['A', '2007-01-01', '2007-12-31'],
                     ['SV', '2007-06-01', nil]
            }.to raise_error(IncompatiblePartyMembershipError)
          end

          it 'works if any of the memberships are within an existing membership for the same party'  do
            import ['A', '2007-01-01', '2007-12-31'],
                   ['A', '2007-06-01', '2007-08-15']

            actual_memberships.should == [
              ['A', '2007-01-01', '2007-12-31']
            ]
          end

          it 'extends an an existing membership for the same party' do
            import ['A', '2007-01-01', '2007-12-31'],
                   ['A', '2007-06-01', '2008-09-30']

            actual_memberships.should == [
              ['A', '2007-01-01', '2008-09-30']
            ]
          end

          it "does not change end_date to nil if current end_date is in the future"  do
            Date.stub(:today).and_return(Date.new(2007, 10, 1))

            import ['A', '2007-01-01', '2007-12-31'],
                   ['A', '2007-06-01', nil]

            actual_memberships.should == [
              ['A', '2007-01-01', '2007-12-31']
            ]
          end

          it "does not change end_date to nil if there's a party mismatch"  do
            expect {
              import ['A', '2007-01-01', '2007-12-31'],
                     ['SV', '2007-06-01', nil]
            }.to raise_error(IncompatiblePartyMembershipError)
          end

          it "changes end_date to nil if party matches"  do
            Date.stub(:today).and_return(Date.new(2008, 2, 1))

            import ['A', '2007-01-01', '2007-12-31'],
                   ['A', '2007-06-01', nil]

            actual_memberships.should == [
              ['A', '2007-01-01', nil]
            ]
          end

          it 'ignores memberships that extends an open ended membership for the same party' do
            import ['A', '2009-01-01', nil],
                   ['A', '2010-01-01', nil]

            actual_memberships.should == [
              ['A', '2009-01-01', nil]
            ]
          end

          it "closes the previous membership and creates a new one if the party was changed" do
            import ['A', '2009-01-01', nil]
            import ['H', '2012-08-01', nil]

            actual_memberships.should == [
              ["A", "2009-01-01", "2012-07-31"],
              ["H", "2012-08-01", nil]
            ]
          end

          it 'processes memberships out of order' do
            import ['H', '2012-08-01', nil],
                   ['A', '2009-01-01', nil]

            actual_memberships.should == [
              ["A", "2009-01-01", "2012-07-31"],
              ["H", "2012-08-01", nil]
            ]
          end

          it 'can end an existing open ended membership' do
            import ['H', '2009-01-01', nil]
            import ['H', '2009-01-01', '2010-09-01']

            actual_memberships.should == [
              ['H', '2009-01-01', '2010-09-01']
            ]
          end

          it 'can move both start and end date' do
            import ['SV', '2009-01-01', '2010-01-01']
            import ['SV', '2008-01-01', '2011-01-01']

            actual_memberships.should == [
              ['SV', '2008-01-01', '2011-01-01']
            ]
          end

          it 'can change an existing membership to open ended' do
            import ['SV', '2009-01-01', '2010-01-01']
            import ['SV', '2008-01-01', nil]

            actual_memberships.should == [
              ['SV', '2008-01-01', nil]
            ]
          end

          it 'handles a representative that is without a party for a while' do
            import ['H', '2009-01-01', nil]
            import ['H', '2009-01-01', '2010-01-01'] # membership ends

            actual_memberships.should == [
              ['H', '2009-01-01', '2010-01-01']
            ]
            representative.party_at(Date.parse('2011-01-01')).should be_nil

            import ['A', '2012-01-01', nil]

            actual_memberships.should == [
              ['H', '2009-01-01', '2010-01-01'],
              ['A', '2012-01-01', nil]
            ]
          end

          it 'handles a representative that rejoins the same party' do
            import ['H', '2009-01-01', nil]
            import ['H', '2009-01-01', '2010-01-01'] # membership ends

            actual_memberships.should == [
              ['H', '2009-01-01', '2010-01-01']
            ]

            import ['H', '2012-01-01', nil]

            actual_memberships.should == [
              ['H', '2009-01-01', '2010-01-01'],
              ['H', '2012-01-01', nil]
            ]

            representative.party_at(Date.parse('2009-06-01')).external_id.should == 'H'
            representative.party_at(Date.parse('2011-01-01')).should be_nil
            representative.party_at(Date.parse('2012-01-02')).external_id.should == 'H'
          end

          it 'fails if an existing membership is expanded into another' do
            import ['H', '2009-01-01', '2010-01-01'],
                   ['A', '2010-02-01', '2011-01-01']

            actual_memberships.should == [
              ['H', '2009-01-01', '2010-01-01'],
              ['A', '2010-02-01', '2011-01-01']
            ]

            expect {
              import ['A', '2009-12-31', nil]
            }.to raise_error(IncompatiblePartyMembershipError)
          end
        end

      end
    end
  end
end
