module Hdo
  module Utils
    class MembershipMerger
      VALID_TYPES = %w[party committee]

      def initialize(type)
        unless VALID_TYPES.include?(type.to_s)
          raise ArgumentError, "expected #{VALID_TYPES.inspect}, got: #{type}"
        end

        @type = type.to_sym
        @relation = "#{type}_memberships".to_sym
      end

      def duplicates
        dups = {}

        reps = Representative.joins(@relation).where("(select count(*) from #{@relation} where representative_id = representatives.id) > 1").all
        reps.each do |r|
          memberships = r.__send__(@relation)
          dups[r] = memberships if memberships.map(&"#{@type}_id".to_sym).uniq.size == 1
        end

        dups
      end

      def print
        duplicates.each do |rep, memberships|
          puts rep.name
          memberships.each { |ms| print_membership ms }
        end
      end

      def merge!
        duplicates.each do |rep, memberships|
          club       = memberships.first.__send__(@type)
          start_date = memberships.map(&:start_date).min
          end_date   = memberships.any?(&:open_ended?) ? nil : memberships.map(&:end_date).max

          puts "merging memberships for #{rep.name}"
          puts "from"
          memberships.each { |ms| print_membership ms }

          rep.__send__(@relation).clear
          ms = rep.__send__(@relation).create!(start_date: start_date, end_date: end_date, @type => club)

          puts "to"
          print_membership(ms)
        end
      end

      private

      def print_membership(ms)
        puts "\t#{ms.__send__(@type).name}: #{ms.start_date} .. #{ms.end_date}"
      end

    end
  end
end