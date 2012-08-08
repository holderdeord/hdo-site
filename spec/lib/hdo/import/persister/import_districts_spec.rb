require 'spec_helper'

module Hdo
  module Import
    describe Persister do
      context 'districts' do

        include_context :persister

        it 'imports a district' do
          xdis = StortingImporter::District.example

          persister.import_district xdis
          District.count.should == 1

          dis = District.first
          dis.external_id.should == xdis.external_id
          dis.name.should == xdis.name
        end

        it 'imports multiple districts' do
          a = StortingImporter::District.new('1', 'foo')
          b = StortingImporter::District.new('2', 'bar')

          persister.import_districts [a, b]

          District.count.should == 2
        end

        it 'updates an existing district based on external_id' do
          xdis = StortingImporter::District.example

          persister.import_district xdis
          District.count.should == 1

          update = StortingImporter::District.new(xdis.external_id, 'changed-name')
          persister.import_district update

          District.count.should == 1
          com = District.first
          com.external_id.should == xdis.external_id
          com.name.should == 'changed-name'
        end

      end
    end
  end
end
