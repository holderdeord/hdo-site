require 'nokogiri'

module Hdo
  module Import
    Field = Struct.new(:name, :required, :type, :description)

    def self.external_id_field
      Field.new(:externalId, false, :string, 'An optional external id, matching potential id fields in the input data. This is useful if you want to reimport previous data without creating duplicates.')
    end
  end
end

require 'hdo/import/representative'
require 'hdo/import/party'
require 'hdo/import/issue'
require 'hdo/import/topic'
require 'hdo/import/committee'

require 'hdo/import/cli'
