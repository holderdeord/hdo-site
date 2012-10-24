module Hdo
  module Model
    module Searchable
      def self.included(base)
        base.extend ClassMethods
        base.__send__ :include, Tire::Model::Search
        base.__send__ :include, Tire::Model::Callbacks
      end

      module ClassMethods
      end

    end
  end
end