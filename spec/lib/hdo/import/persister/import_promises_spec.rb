require 'spec_helper'

module Hdo
  module Import
    describe Persister do
      context 'promises' do

        include_context :persister

        it 'should import a promise' do
          example = Hdo::StortingImporter::Promise.example
          example.categories.each do |cat|
            Category.make!(:name => cat)
          end
          Party.make! :external_id => example.parties.first

          persister.import_promises [example]

          Promise.count.should == 1
          promise = Promise.first

          promise.external_id.should == example.external_id
          promise.parties.map(&:external_id).should == example.parties
          promise.body.should == example.body
          promise.categories.map(&:name).should == example.categories
          promise.source.should == example.source
          promise.page.should == example.page
          promise.general.should == example.general
        end
      end
    end
  end
end
