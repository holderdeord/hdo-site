module Hdo
  class IssueUpdater

    def initialize(issue, attributes, votes, user)
      @issue      = issue
      @attributes = attributes
      @votes      = votes
      @user       = user
    end

    def execute
      execute!
    rescue ActiveRecord::StaleObjectError
      @issue.errors.add :base, "Kunne ikke lagre, saken er blitt endret i mellomtiden."
      false
    end

    def execute!
      @changed = false

      @user.transaction {
        update_votes
        update_attributes
        update_meta
        save
      }
    end

    private

    def update_votes
      Array(@votes).each do |vote_id, data|
        update_or_create_vote_connection(vote_id, data)
      end
    end

    def update_attributes
      return unless @attributes

      @changed ||= (association_changed?(:category_ids) || association_changed?(:promise_ids) || association_changed?(:topic_ids))
      @issue.attributes = @attributes
      @changed ||= @issue.changed?
    end

    def update_meta
      return unless @changed

      @issue.updated_at = Time.now
      @issue.last_updated_by = @user
    end

    def update_or_create_vote_connection(vote_id, data)
      existing = VoteConnection.where('vote_id = ? and issue_id = ?', vote_id, @issue.id).first

      if data[:direction] == 'unrelated'
        if existing
          @issue.vote_connections.delete existing
          @changed = true
        end
      else
        attrs = data.except(:direction, :proposition_type).merge(matches: data[:direction] == 'for', vote_id: vote_id)

        if existing
          # @changed ||= update_vote_proposition_type existing.vote, data[:proposition_type]

          existing.vote.proposition_type = data[:proposition_type]
          @changed ||= existing.vote.changed?
          existing.vote.save

          existing.attributes = attrs
          @changed ||= existing.changed?

          existing.save!
        else
          new_connection = @issue.vote_connections.create!(attrs)
          # update_vote_proposition_type new_connection.vote, data[:proposition_type]
          new_connection.vote.proposition_type = data[:proposition_type]
          new_connection.vote.save
          @changed = true
        end
      end
    end

    def association_changed?(name)
      edit = @attributes[name.to_s]
      orig = @issue.__send__(name)

      edit && (edit.reject(&:empty?).map(&:to_i).sort != orig.sort)
    end

    def save
      @issue.save
    end

  end
end