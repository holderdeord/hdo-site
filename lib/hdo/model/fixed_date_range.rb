module Hdo
  module Model
    module FixedDateRange
      extend ActiveSupport::Concern

      included do
        attr_accessible :start_date, :end_date
      end

      def include?(date)
        date >= start_date && date <= end_date
      end

      def name
        [start_date.year, end_date.year].join('-')
      end

      module ClassMethods
        def named(name)
          all.find { |e| e.name == name }
        end

        def for_date(date)
          where('start_date <= date(?) AND end_date >= date(?)', date, date).first
        end

        def current
          for_date Date.current
        end

        def previous
          where('end_date < ?', current.start_date).order(:end_date).first
        end

        def next
          where('start_date > ?', current.end_date).order(:start_date).first
        end
      end
    end
  end
end