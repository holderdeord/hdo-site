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

      def current?
        include? Date.today
      end

      def name
        [start_date.year, end_date.year].join('-')
      end

      def votes
        Vote.where("time >= ? AND time <= ?", start_date, end_date)
      end

      module ClassMethods
        def named(name)
          all.find { |e| e.name == name }
        end

        def for_date(date)
          date = date.to_date
          where('start_date <= date(?) AND end_date >= date(?)', date, date).first
        end

        def current
          for_date Date.current
        end

        def previous
          c = current or return
          where('end_date < ?', c.start_date).order('start_date DESC').first
        end

        def next
          c = current or return 
          where('start_date > ?', c.end_date).order(:start_date).first
        end
      end
    end
  end
end
