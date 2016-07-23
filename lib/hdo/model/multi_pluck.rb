# multi_pluck.rb
require 'active_support/concern'

module Hdo
  module Model
    module MultiPluck
      extend ActiveSupport::Concern

      included do
        def self.pluck_all(relation, *args)
          connection.select_all(relation.select(args))
        end
      end
    end
  end
end