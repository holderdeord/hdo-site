module Hdo
  class IssueUpdater

    def initialize(issue, attributes, votes, user)
      @issue      = issue
      @attributes = attributes
      @votes      = votes
      @user       = user
    end

    def execute
      @user.transaction { update_attributes_and_votes }
    end

    private

    def update_attributes_and_votes
      changed = false

      Array(@votes).each do |vote_id, data|
        existing = VoteConnection.where('vote_id = ? and issue_id = ?', vote_id, @issue.id).first

        if data[:direction] == 'unrelated'
          if existing
            @issue.vote_connections.delete existing
            changed = true
          end
        else
          attrs = data.except(:direction, :proposition_type).merge(matches: data[:direction] == 'for', vote_id: vote_id)

          if existing
            # changed ||= update_vote_proposition_type existing.vote, data[:proposition_type]

            existing.vote.proposition_type = data[:proposition_type]
            changed ||= existing.vote.changed?
            existing.vote.save

            existing.attributes = attrs
            changed ||= existing.changed?

            existing.save!
          else
            new_connection = @issue.vote_connections.create!(attrs)
            # update_vote_proposition_type new_connection.vote, data[:proposition_type]
            new_connection.vote.proposition_type = data[:proposition_type]
            new_connection.vote.save
            changed = true
          end
        end
      end

      if @attributes
        # TODO: find a better way to do this!

        if @attributes['category_ids'] && @attributes['category_ids'].reject(&:empty?).map(&:to_i).sort != @issue.category_ids.sort
          changed = true
        end

        if @attributes['promise_ids'] && @attributes['promise_ids'].reject(&:empty?).map(&:to_i).sort != @issue.promise_ids.sort
          changed = true
        end

        if @attributes['topic_ids'] && @attributes['topic_ids'].reject(&:empty?).map(&:to_i).sort != @issue.topic_ids.sort
          changed = true
        end

        @issue.attributes = @attributes
        changed ||= @issue.changed?
      end

      if changed
        @issue.updated_at = Time.now
        @issue.last_updated_by = @user
      end

      @issue.save
    end

    def update_vote_proposition_type(vote, proposition_type)
      vote.proposition_type = proposition_type
      changed = vote.changed?
      vote.save
      changed
    end

  end
end