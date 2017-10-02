require 'spec_helper'

module Hdo
  module Import
    describe CLI do
      before do
        ParliamentSession.make!(:current)
        ParliamentPeriod.make!(:current)
      end

      it 'has a default session and period' do
        opts = CLI.new(['api']).options

        # if this fails, make sure the :current blueprints are up to date
        opts[:session].should =~ /^\d{4}-\d{4}$/
        opts[:period].should  =~ /^\d{4}-\d{4}$/
      end

      it 'raises on unknown commands' do
        expect {
          CLI.new(['foo']).run
        }.to raise_error(ArgumentError)
      end
    end
  end
end
