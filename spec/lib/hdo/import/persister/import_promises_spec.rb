require 'spec_helper'

module Hdo
  module Import
    describe Persister do
      context 'promises' do

        include_context :persister

        it 'should import a promise' do
          example = Hdo::StortingImporter::Promise.example
          example.categories.each { |c| Category.make!(name: c) }
          ParliamentPeriod.make!(external_id: '2009-2013')
          Party.make! external_id: example.promisor.first

          persister.import_promises [example]

          Promise.count.should == 1
          promise = Promise.first

          promise.external_id.should == example.external_id
          promise.promisor.external_id.should == example.promisor
          promise.body.should == example.body
          promise.categories.map(&:name).should == example.categories
          promise.source.should == example.source
          promise.page.should == example.page
          promise.general.should == example.general
          promise.parliament_period.name.should == '2009-2013'
        end

        it 'imports a government promise' do
          ParliamentPeriod.make!(external_id: '2009-2013')
          Government.make!(name: 'Stoltenberg II', parties: [Party.make!])

          example = Hdo::StortingImporter::Promise.example('promisor' => 'Stoltenberg II')
          example.categories.each { |c| Category.make!(name: c) }

          persister.import_promises [example]

          Promise.count.should == 1
          Promise.first.promisor.should == Government.first
        end

        it 'fails if the promise has no promisor' do
          promise = Hdo::StortingImporter::Promise.example('promisor' => nil)

          expect {
            persister.import_promises [promise]
          }.to_not change(Promise, :count)
        end
      end
    end
  end
end
