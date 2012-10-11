require 'spec_helper'

module Hdo
  module Import
    describe CLI do
      it 'has a default session and period' do
        CLI.new(['api']).options.should include(
          session: '2012-2013',
          period:  '2009-2013'
        )
      end

      it 'raises on unknown commands' do
        expect {
          CLI.new(['foo']).run
        }.to raise_error(ArgumentError)
      end
    end
  end
end
