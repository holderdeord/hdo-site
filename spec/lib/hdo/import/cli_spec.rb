require 'spec_helper'

module Hdo
  module Import
    describe CLI do
      it 'has a default session and period' do
        CLI.new(['api']).options.should include(
          session: '2013-2014',
          period:  '2013-2017'
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
