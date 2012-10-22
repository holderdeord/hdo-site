module Hdo
  module ModelHelpers
    module HasDateRange

      def self.included(base)
        base.validate :start_date_must_be_before_end_date
        base.validates_presence_of :start_date

        base.scope :for_date, lambda { |date| base.where('start_date <= date(?) AND (end_date >= date(?) OR end_date IS NULL)', date, date) }
        base.scope :current, lambda { base.for_date(Time.current) }
      end

      def current?
        include? Time.current
      end

      def include?(date)
        date >= start_date && (end_date == nil || date <= end_date)
      end

      def intersects?(other)
        if start_date == other.start_date
          true
        elsif start_date > other.start_date
          start_date <= (other.end_date || Date.today)
        else
          other.start_date <= (end_date || Date.today)
        end
      end

      def open_ended?
        end_date.nil?
      end

      private

      #
      # validations
      #

      def start_date_must_be_before_end_date
        if start_date && end_date && start_date >= end_date
          errors.add(:start_date, "must be before end date")
        end
      end

    end
  end
end