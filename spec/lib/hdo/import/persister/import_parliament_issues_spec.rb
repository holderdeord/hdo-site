require 'spec_helper'

module Hdo
  module Import
    describe Persister do
      context 'parliament issues' do

        include_context :persister

        def setup_parliament_issue(issue)
          Committee.find_or_create_by_name!(issue.committee, external_id: issue.committee[0..5])
          issue.categories.each { |c| Category.find_or_create_by_name!(c, external_id: c[0..5]) }
        end

        it 'imports a parliament issue' do
          parliament_issue = StortingImporter::ParliamentIssue.example
          setup_parliament_issue(parliament_issue)

          persister.import_parliament_issue parliament_issue
          ParliamentIssue.count.should == 1
        end

        it 'imports multiple parliament issues' do
          first  = StortingImporter::ParliamentIssue.example
          second = StortingImporter::ParliamentIssue.example('external_id' => '1234', 'status' => 'behandlet')

          setup_parliament_issue(first)
          setup_parliament_issue(second)

          persister.import_parliament_issues [first, second]

          ParliamentIssue.count.should == 2
        end

        it 'updates an existing parliament issue based on external id' do
          parliament_issue = StortingImporter::ParliamentIssue.example
          setup_parliament_issue(parliament_issue)

          persister.import_parliament_issue parliament_issue
          ParliamentIssue.count.should == 1

          update = StortingImporter::ParliamentIssue.example('status' => 'behandlet')

          persister.import_parliament_issue update
          ParliamentIssue.count.should == 1

          pi = ParliamentIssue.first
          pi.external_id.should == parliament_issue.external_id
          pi.status.should == update.status
        end

      end
    end
  end
end
