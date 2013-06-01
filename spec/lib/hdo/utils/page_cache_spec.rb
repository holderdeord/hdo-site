require 'spec_helper'

module Hdo
  module Utils

    describe PageCache do
      let(:purger) { mock }
      let(:cache) { PageCache.new(purger) }

      it 'should expire an issue' do
        issue = Issue.make!
        actual = []

        purger.stub(:add).with do |url|
          actual << url
        end

        purger.should_receive(:execute)

        cache.expire_issue(issue)

        expected = [
          "http://localhost:3000/issues",
          "http://localhost:3000/issues/#{issue.to_param}",
          "http://localhost:3000/issues/#{issue.to_param}/votes",
        ]

        expected += Party.all.flat_map do |p|
          [
            "http://localhost:3000/parties/#{p.slug}",
          ]
        end

        expected += Representative.all.flat_map do |r|
           [
             "http://localhost:3000/representatives/#{r.slug}",
           ]
        end

        actual.should == expected
      end

      it 'should expire a question'
    end
  end
end