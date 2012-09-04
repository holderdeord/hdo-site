require 'spec_helper'

module Hdo
  module Import
    describe Persister do
      context 'parliament issues' do

        include_context :persister

        it 'imports a parliament issue'
        it 'updates an existing parliament issue based on external id'

      end
    end
  end
end
