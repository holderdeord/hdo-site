require 'spec_helper'

module Hdo
  module Import
    describe Persister do
      context 'categories' do

        include_context :persister

        it 'imports multiple categories' do
          a = StortingImporter::Category.new('1', 'foo')
          b = StortingImporter::Category.new('2', 'bar')

          persister.import_categories [a, b]

          Category.count.should == 2
        end

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
    end
  end
end
