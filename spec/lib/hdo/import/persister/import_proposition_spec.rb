require 'spec_helper'

module Hdo
  module Import
    describe Persister do
      context 'parties' do

        include_context :persister

        it 'imports a proposition' do
          prop = Hdo::StortingImporter::Proposition.example
          Party.make!(:name => prop.delivered_by.party)
          Committee.make!(:name => prop.delivered_by.committees.first)
          District.make!(:name => prop.delivered_by.district)

          persister.import_propositions [prop]

          Proposition.count.should == 1
        end

        # https://github.com/holderdeord/hdo-site/issues/138
        it 'imports a proposition with external_id = -1'

      end
    end
  end
end
