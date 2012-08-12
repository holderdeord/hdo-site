require 'spec_helper'

module Hdo
  module Import
    describe Persister do
      context 'parties' do

        include_context :persister

        let(:example) do
          prop = Hdo::StortingImporter::Proposition.example

          Party.make!(:name => prop.delivered_by.party)
          Committee.make!(:name => prop.delivered_by.committees.first)
          District.make!(:name => prop.delivered_by.district)

          prop
        end

        it 'imports a proposition' do
          persister.import_propositions [example]

          Proposition.count.should == 1
          prop = Proposition.first
          prop.delivered_by.should be_kind_of(Representative)
        end

        # https://github.com/holderdeord/hdo-site/issues/138
        it 'imports a proposition with external_id -1' do
          hash = example.to_hash.tap { |e| e['externalId'] = '-1' }

          prop = Hdo::StortingImporter::Proposition.from_hash(hash)
          persister.import_propositions [prop]

          Proposition.count.should == 1

          imported = Proposition.first
          imported.external_id.should be_nil
        end

        it 'ignores propositions with external_id=-1, body="" and description=""' do
          hash = example.to_hash.tap do |e|
            e.merge!('externalId' => '-1', 'body' => '', 'description' => '')
          end

          prop = Hdo::StortingImporter::Proposition.from_hash(hash)
          persister.import_propositions [prop]

          Proposition.count.should == 0
        end

      end
    end
  end
end
