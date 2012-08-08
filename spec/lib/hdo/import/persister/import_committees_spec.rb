require 'spec_helper'

module Hdo
  module Import
    describe Persister do
      context 'commitees' do

        include_context :persister

        it 'imports a committee' do
          xcom = StortingImporter::Committee.example

          persister.import_committee xcom
          Committee.count.should == 1

          com = Committee.first
          com.external_id.should == xcom.external_id
          com.name.should == xcom.name
        end

        it 'updates an existing committee based on external_id' do
          xcom = StortingImporter::Committee.example

          persister.import_committee xcom
          Committee.count.should == 1

          update = StortingImporter::Committee.new(xcom.external_id, 'changed-name')
          persister.import_committee update

          Committee.count.should == 1
          com = Committee.first
          com.external_id.should == xcom.external_id
          com.name.should == 'changed-name'
        end

      end
    end
  end
end
