module Hdo
  module Import
    class PartyMembershipUpdater

      def initialize(representative, memberships)
        @representative = representative
        @memberships = memberships.sort_by(&sorter)

        @party_cache = {}
      end

      def today
        @today ||= Date.today
      end

      def sorter
        lambda { |e| [e.start_date, e.end_date || today]}
      end

      def update
        @memberships.each { |membership| update_membership(membership) }
      end

      private

      def update_membership(membership)
        intersections = current_intersections_for(membership)

        # TODO extend if no intersection, but continuous
        if intersections.any?
          handle_intersections(intersections, membership)
        elsif e = continuous_membership_after(membership)
          e.update_attributes({ start_date: membership.start_date })
        else
          create_new_membership(membership)
        end
      rescue ActiveRecord::RecordInvalid => ex
        raise IncompatiblePartyMembershipError, "#{ex.message} for #{ex.record.inspect} / #{inspect_representative}"
      end

      def continuous_membership_after(membership)
        current_memberships.select { |e| e.start_date - (membership.end_date || e.start_date) == 1 }.first
      end

      def party_for(membership)
        @party_cache[membership.external_id] ||= Party.find_by_external_id!(membership.external_id)
      end

      def current_intersections_for(membership)
        current_memberships.select { |e| e.intersects?(membership) }
      end

      def handle_intersections(intersections, membership)
        if intersections.size == 1
          existing = intersections.first

          if existing.party == party_for(membership)
            expand(existing, membership)
          elsif existing.open_ended?
            # party change. set the end_date to the day before the new membership starts
            existing.update_attributes!(end_date: membership.start_date - 1)
            create_new_membership(membership)
          else
            incompatible "tried to add #{membership.inspect} #{inspect_representative}, which intersects with an existing membership in other parties: #{inspect_intersections intersections}"
          end
        else
          incompatible "tried to add #{membership.inspect} to #{inspect_representative}, which intersects with multiple existing memberships: #{inspect_intersections intersections}"
        end
      end

      def expand(existing, membership)
        updates = {}

        if membership.start_date < existing.start_date
          updates[:start_date] = membership.start_date
        end

        if membership.end_date == existing.end_date
          # do nothing
        elsif membership.end_date.nil?
          updates[:end_date] = nil if existing.end_date <= today
        elsif existing.open_ended? && membership.end_date
          updates[:end_date] = membership.end_date
        elsif existing.end_date && membership.end_date > existing.end_date
          updates[:end_date] = membership.end_date
        end

        existing.update_attributes!(updates) unless updates.empty?
      end

      def current_memberships
        @representative.party_memberships.to_a.sort_by(&sorter)
      end

      def create_new_membership(membership)
        @representative.party_memberships.create!(
          party:      party_for(membership),
          start_date: membership.start_date,
          end_date:   membership.end_date
        )
      end

      def inspect_intersections(existing_memberships)
        existing_memberships.map { |ms| "[party=#{ms.party.external_id} start_date=#{ms.start_date} end_date=#{ms.end_date}]" }.join(", ")
      end

      def inspect_representative
        "#{@representative.full_name} (#{@representative.external_id})"
      end

      def incompatible(msg)
        raise IncompatiblePartyMembershipError, msg
      end

    end # PartyMembershipUpdater
  end # Import
end # Hdo
