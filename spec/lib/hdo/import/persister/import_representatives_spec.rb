require 'spec_helper'

module Hdo
  module Import
    describe Persister do
      context 'representatives' do

        include_context :persister

        def setup_representative(rep)
          # party, district and committees must already be imported
          Party.make!(:name => rep.party)
          District.make!(:name => rep.district)
          rep.committees.map { |e| Committee.make!(:name => e) }
        end

        it 'imports a representative' do
          example = StortingImporter::Representative.example
          setup_representative(example)

          persister.import_representative example

          Representative.count.should == 1

          rep = Representative.first
          rep.first_name.should == example.first_name
          rep.last_name.should == example.last_name
        end

        it 'updates an existing representative based on external id' do
          example = StortingImporter::Representative.example
          setup_representative(example)

          persister.import_representative example

          Representative.count.should == 1

          update = StortingImporter::Representative.example('firstName' => 'changed-name')
          persister.import_representative update

          Representative.count.should == 1
          Representative.first.first_name.should == 'changed-name'
        end

      end
    end
  end
end
