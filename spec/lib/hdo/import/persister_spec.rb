require 'spec_helper'

module Hdo
  module Import
    describe Persister do
      let :persister do
        persister = Persister.new
        persister.log = Logger.new(File::NULL)

        persister
      end
      
      # TODO: specs for the remaining types

      context 'commitees' do
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

      context 'category' do
        it 'imports a category' do
          xcat = StortingImporter::Category.example

          persister.import_category xcat
          Category.count.should == 2 # has 1 child

          cat = Category.find_by_external_id(xcat.external_id)
          cat.external_id.should == xcat.external_id
          cat.name.should == xcat.name
          cat.children.map(&:name).should == xcat.children.map(&:name)
        end

        it 'updates an existing category based on external_id' do
          xcat = StortingImporter::Category.example

          persister.import_category xcat
          Category.count.should == 2 # has 1 child

          update = StortingImporter::Category.new(xcat.external_id, 'changed-name')
          persister.import_category update

          Category.count.should == 2
          cat = Category.find_by_external_id(xcat.external_id)
          cat.name.should == 'changed-name'
        end
      end

      context 'district' do
        it 'imports a district' do
          xdis = StortingImporter::District.example

          persister.import_district xdis
          District.count.should == 1

          dis = District.first
          dis.external_id.should == xdis.external_id
          dis.name.should == xdis.name
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
