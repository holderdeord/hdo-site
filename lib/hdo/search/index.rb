module Hdo
  module Search
    module Index

      def update_index_on_change_of(*classes)
        if classes.last.kind_of?(Hash)
          opts = classes.pop
        else
          opts = {}
        end

        classes.map! { |a| a.to_s.classify.constantize }

        updater = ->(model) do
          if opts[:if].nil? || opts[:if].call(model)
            model.tire.update_index
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

    end # Index
  end # Search
end # Hdo
