require 'nokogiri'

module Hdo
  module Import
    Field = Struct.new(:name, :required, :type, :description)

    def self.external_id_field
      Field.new(:externalId, false, :string, 'An optional external id, matching potential id fields in the input data. This is useful if you want to reimport previous data without creating duplicates.')
    end

    class Type
      def self.indent(str, spaces = 2)
        str.split("\n").map { |e| "#{' ' * spaces}#{e}" }.join("\n")
      end
    end
  end
end


# require 'hdo/import/representative'
# require 'hdo/import/proposition'
# require 'hdo/import/party'
# require 'hdo/import/issue'
# require 'hdo/import/category'
# require 'hdo/import/committee'
# require 'hdo/import/district'
# require 'hdo/import/vote'
# require 'hdo/import/promise'

require 'hdo/storting_importer'
require 'hdo/import/cli'
