module Hdo
  module Search
    module Index

      def update_index_on_change_of(*args)
        singular = self.to_s.downcase
        plural   = singular.pluralize
        classes  = args.map { |a| a.to_s.singularize.capitalize.constantize }

        classes.each do |clazz|
          if clazz.method_defined? singular
            clazz.send :after_save, "#{singular}.tire.update_index"
          elsif clazz.method_defined? plural
            clazz.send :after_save, "#{plural}.each {|e| e.tire.update_index}"
          end

        end
      end

    end # Search
  end # Search
end # Hdo
