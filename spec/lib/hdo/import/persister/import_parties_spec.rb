# encoding: UTF-8
require 'spec_helper'

module Hdo
  module Import
    describe Persister do
      context 'parties' do

        include_context :persister

        it 'imports multiple parties' do
          a = StortingImporter::Party.new('A', 'Arbeiderpartiet')
          b = StortingImporter::Party.new('H', 'Høyre')

          persister.import_parties [a, b]

          Party.count.should == 2
        end

        it 'imports a party' do
          xparty = StortingImporter::Party.example

          persister.import_party xparty
          Party.count.should == 1

          party = Party.find_by_external_id(xparty.external_id)

          party.external_id.should == xparty.external_id
          party.name.should == xparty.name

          gp = party.governing_periods.last
          gp.should be_kind_of(GoverningPeriod)
          gp.start_date.should == xparty.governing_periods.last.start_date
          gp.end_date.should == xparty.governing_periods.last.end_date
        end

        it 'fails if the party is invalid' do
          invalid = StortingImporter::Party.new('1', nil)

          expect {
            persister.import_party invalid
          }.to raise_error(Hdo::StortingImporter::ValidationError)
        end

        it 'updates an existing party based on external_id' do
          xparty = StortingImporter::Party.example
          persister.import_party xparty
          Party.count.should == 1

          update = StortingImporter::Party.new(xparty.external_id, 'changed-name')
          persister.import_party update

          Party.count.should == 1
          cat = Party.find_by_external_id(xparty.external_id)
          cat.name.should == 'changed-name'
        end

        it 'overwrites existing governing periods' do
          persister.import_party StortingImporter::Party.example

          changed = StortingImporter::Party.example
          changed.governing_periods = []

          persister.import_party changed

          GoverningPeriod.count.should == 0
        end
      end
    end
  end
end
