module Hdo
  module Utils
    class PartyMembershipMerger
      def duplicates
        dups = {}

        reps = Representative.joins(:party_memberships).where('(select count(*) from party_memberships where representative_id = representatives.id) > 1').all
        reps.each do |r|
          memberships = r.party_memberships
          dups[r] = memberships if memberships.map(&:party_id).uniq.size == 1
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
          party      = memberships.first.party
          start_date = memberships.map(&:start_date).min
          end_date   = memberships.any?(&:open_ended?) ? nil : memberships.map(&:end_date).max

          puts "merging memberships for #{rep.name}"
          puts "from"
          memberships.each { |ms| print_membership ms }

          rep.party_memberships.clear
          ms = rep.party_memberships.create!(start_date: start_date, end_date: end_date, party: party)

          puts "to"
          print_membership(ms)
        end
      end

      private

      def print_membership(ms)
        puts "\t#{ms.party.name}: #{ms.start_date} .. #{ms.end_date}"
      end

    end
  end
end