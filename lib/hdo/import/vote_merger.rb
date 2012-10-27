module Hdo
  module Import

    #
    # temporary tool to merge duplicate votes
    # see https://github.com/holderdeord/hdo-site/issues/317
    #

    class VoteMerger

      def self.execute
        new.execute
      end

      def execute
        duplicates.each { |dups| merge(dups) }
      end

      def merge(duplicates)
        master = duplicates.sort_by { |e| e.propositions.size }.last
        duplicates.delete(master)

        duplicates.each do |dup|
          dup.vote_connections.each do |vc|
            new_vc = master.vote_connections.find_or_create_by_issue_id!(vc.issue_id)

            attrs = vc.attributes.slice(:matches, :issue_id, :weight, :comment, :title)
            new_vc.update_attributes!(attrs)
          end

          dup.destroy
        end

      end

      def duplicates
        grouped = Vote.all.group_by { |e| e.time }
        duplicates = grouped.select { |time, votes|
          case votes.size
          when 1
            false
          when 2
            # check for 'alternativ votering'
            a, b = votes
            !a.alternate_of?(b)
          else
            true
          end
        }

        duplicates.values
      end

    end
  end
end