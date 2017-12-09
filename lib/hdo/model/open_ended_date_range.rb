module Hdo
  module Model
    module OpenEndedDateRange
      extend ActiveSupport::Concern

      included do
        validate :start_date_must_be_before_end_date
        validates_presence_of :start_date

        scope :for_date, ->(date) do
          where('start_date <= date(?) AND (end_date >= date(?) OR end_date IS NULL)', date, date)
        end

        scope :current, -> { for_date Date.current }
      end

      def current?
        include? Date.current
      end

      def include?(date)
        s, e = start_date.to_date, end_date.try(:to_date)

        date = date.try(:to_date) || date # convert time to date
        date >= s && (e == nil || date <= e)
      end

      def intersects?(other)
        this_start_date  = start_date.to_date
        this_end_date    = end_date.try :to_date
        other_start_date = other.start_date.to_date
        other_end_date   = other.end_date.try :to_date

        if this_start_date == other_start_date
          true
        elsif this_start_date > other_start_date
          other_end_date.nil? || this_start_date <= other_end_date
        else
          this_end_date.nil? || other_start_date <= this_end_date
        end
      end

      def open_ended?
        end_date.nil?
      end

      private

      def start_date_must_be_before_end_date
        if start_date && end_date && start_date > end_date
          errors.add(:start_date, "must be before end date")
        end
      end

    end
  end
end