module Hdo
  module Search
    module Index

      def update_index_on_change_of(*args)
        singular = self.to_s.underscore
        plural   = singular.pluralize
        if args.last == :has_many
          classes = args[0..-2]
        else
          classes = args
        end
        classes.map! { |a| a.to_s.classify.constantize }

        classes.each do |clazz|
          if args.last == :has_many
            clazz.send :after_save, "#{plural}.each {|e| e.tire.update_index}"
          else
            clazz.send :after_save, "#{singular}.tire.update_index"
          end
        end
      end

    end # Search
  end # Search
end # Hdo
