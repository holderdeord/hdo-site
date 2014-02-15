module Hdo
  module Search
    module Index
      extend ActiveSupport::Concern

      included do
        include Elasticsearch::Model
        index_name "hdo_#{Rails.env}_#{index_name}"
      end

      module ClassMethods
        #
        # Set up default callbacks
        #
        # By default for :update, ES will do a partial update based on the dirty attributes in the model.
        # If you override #as_indexed_json to include non-attribute data, set :partial_update => false to
        # avoid an outdated index.
        #

        def add_index_callbacks(opts = {})
          after_commit -> { __elasticsearch__.index_document  }, on: :create
          after_commit -> { __elasticsearch__.delete_document }, on: :destroy


          if opts[:partial_update] == false
            after_commit -> { __elasticsearch__.index_document }, on: :update
          else
            after_commit -> { __elasticsearch__.update_document }, on: :update
          end
        end

        def update_index_on_change_of(*classes)
          if classes.last.kind_of?(Hash)
            opts = classes.pop
          else
            opts = {}
          end

          classes.map! { |a| a.to_s.classify.constantize }

          updater = ->(model) do
            if opts[:if].nil? || opts[:if].call(model)
              if model.destroyed?
                model.__elasticsearch__.delete_document
              else
                model.__elasticsearch__.index_document
              end
            end
          end

          singular = self.to_s.underscore
          plural   = singular.pluralize

          fetch_association = opts[:has_many] ? ->(obj) { obj.__send__(plural)       }
                                              : ->(obj) { [ obj.__send__(singular) ] }

          classes.each do |clazz|
            clazz.after_save { fetch_association.call(self).each(&updater) }
          end
        end
      end

    end # Index
  end # Search
end # Hdo
