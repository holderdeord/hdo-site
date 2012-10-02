module Hdo
  module Import
    class CommitteeMembershipUpdater

      def initialize(representative, committees)
        @representative  = representative
        @memberships     = committees.sort_by(&sorter)
        @committee_cache = {}
        @old_memberships = current_memberships
      end

      def today
        @today ||= Date.today
      end

      def sorter
        lambda { |e| [e.start_date, e.end_date || today]}
      end

      def update
        # 1. all input memberships reflect the current state and should be added
        # 2. if one intersects an existing membership in the same committee, we
        #    adjust it to reflect the new data.
        # 3. if an existing, current membership is not present in the new data, it is
        #    closed with end_date = yesterday.
        # 4. start dates in the future are not accepted, input should reflect current state

        @memberships.each do |ms|
          if ms.start_date > today
            incompatible "start date #{ms.start_date} is in the future"
          end
        end

        to_create = @memberships.dup

        @old_memberships.each do |existing|
          to_adjust = @memberships.select { |new| committee_matches?(existing, new) && existing.intersects?(new) }

          if to_adjust.any?
            to_adjust.each { |new| adjust(existing, new) }
            to_create -= to_adjust
          else
            close(existing) if existing.current?
          end
        end

        to_create.each { |m| create_new_membership m }
      end

      def committee_matches?(existing, membership)
        existing.committee == committee_for(membership)
      end

      def close(existing)
        existing.update_attributes! end_date: today - 1
      end

      def adjust(existing, membership)
        updates = {}

        if existing.open_ended? && membership.start_date < existing.start_date
          updates[:start_date] = membership.start_date
        end

        existing.update_attributes(updates) if updates.any?
      end

      private

      def create_new_membership(membership)
        @representative.committee_memberships.create!(
          committee:  committee_for(membership),
          start_date: membership.start_date,
          end_date:   membership.end_date
        )
      rescue ActiveRecord::RecordInvalid => ex
        incompatible "#{membership.inspect} is incompatible with #{inspect_existing current_memberships} for #{inspect_representative}"
      end

      def committee_for(membership)
        @committee_cache[membership.external_id] ||= Committee.find_by_external_id!(membership.external_id)
      end

      def current_memberships
        @representative.committee_memberships.to_a.sort_by(&sorter)
      end

      def current_intersections_for(membership)
        current_memberships.select { |m| m.intersects?(membership) }
      end

      def incompatible(msg)
        raise IncompatibleCommitteeMembershipError, msg
      end

      def inspect_representative
        "#{@representative.full_name} (#{@representative.external_id})"
      end

      def inspect_existing(existing_memberships)
        existing_memberships.map { |ms| "#<committee=#{ms.committee.external_id} start_date=#{ms.start_date} end_date=#{ms.end_date}>" }.join(", ")
      end

    end # CommitteeMembershipUpdater
  end # Import
end # Hdo
