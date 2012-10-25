require 'spec_helper'

module Hdo
  module Import
    describe Persister do

      shared_examples_for 'sessions and periods' do
        include_context :persister

        let(:described_class) { Object.const_get(described_class_name) }
        let(:described_import_class) { StortingImporter.const_get(described_class_name) }

        it 'imports one' do
          xpp = described_import_class.example

          import xpp
          described_class.count.should == 1

          obj = described_class.first
          obj.external_id.should == xpp.external_id
          obj.start_date.should == xpp.start_date
          xpp.end_date.should == xpp.end_date
        end

        it 'imports multiple' do
          a = described_import_class.example('externalId' => '2009-2013')
          b = described_import_class.example('externalId' => '2005-2009')

          import [a, b]

          described_class.count.should == 2
        end

        it 'fails if the input is invalid' do
          invalid = described_import_class.example('endDate' => nil)

          expect {
            import invalid
          }.to raise_error(Hdo::StortingImporter::ValidationError)
        end

        it 'updates existing based on external_id' do
          xpp = described_import_class.example

          import xpp
          described_class.count.should == 1

          update = described_import_class.example('endDate' => '2016-09-13')
          import update

          described_class.count.should == 1
          com = described_class.first
          com.external_id.should == xpp.external_id
          com.start_date.should == update.start_date
          com.end_date.should == update.end_date
        end
      end

      describe 'parliament session' do
        let(:described_class_name) { 'ParliamentSession' }

        def import(obj)
          if obj.kind_of? Array
            persister.import_parliament_sessions obj
          else
            persister.import_parliament_session obj
          end
        end

        it_behaves_like 'sessions and periods'
      end

      describe 'parliament period' do
        let(:described_class_name) { 'ParliamentPeriod' }

        def import(obj)
          if obj.kind_of? Array
            persister.import_parliament_periods obj
          else
            persister.import_parliament_period obj
          end
        end

        it_behaves_like 'sessions and periods'
      end
    end
  end
end
