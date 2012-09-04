require 'spec_helper'

module Hdo
  module Import
    describe Persister do
      context 'representatives' do

        include_context :persister

        it 'imports a representative'
        it 'updates an existing representative based on external id'

      end
    end
  end
end
