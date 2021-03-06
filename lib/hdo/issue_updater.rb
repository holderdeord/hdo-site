module Hdo
  class IssueUpdater

    class Unauthorized < StandardError
    end

    def self.for_proposition(proposition, issue, user)
      Hdo::IssueUpdater.new(issue, {propositions: {proposition.id => [{connected: true}]}}, user)
    end

    def initialize(issue, params, user)
      @issue          = issue
      @attributes     = params[:issue]
      @propositions   = params[:propositions]
      @promises       = params[:promises]
      @party_comments = params[:party_comments]
      @positions      = params[:positions]
      @user           = user
    end

    def update
      update!
    rescue ActiveRecord::StaleObjectError
      @issue.errors.add :base, I18n.t('app.errors.issues.unable_to_save')
      false
    rescue Unauthorized
      @issue.errors.add :base, I18n.t('app.errors.unauthorized')
      false
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => ex
      # failure could be from association
      @issue.errors.empty? && @issue.errors.add(:base, ex.message)
      false
    end

    def update!
      @changed = false

      assert_editing_allowed

      @user.transaction {
        update_attributes
        update_propositions
        update_promises
        update_party_comments
        update_positions
        update_meta
        save!
      }
    end

    private

    def update_propositions
      Array(@propositions).each do |proposition_id, data|
        update_or_create_proposition_connection(proposition_id, data)
      end
    end

    def update_promises
      Array(@promises).each do |promise_id, data|
        update_or_create_promise_connection(promise_id, data)
      end
    end

    def update_party_comments
      Array(@party_comments).each do |comment_id, data|
        update_or_create_or_destroy_party_comment(comment_id, data)
      end
    end

    def update_positions
      Array(@positions).each do |position_id, data|
        update_or_create_or_destroy_position(position_id, data)
      end
    end

    def update_attributes
      return unless @attributes

      # avoid @changed = true for identical tag list
      if @attributes[:tag_list].kind_of?(String)
        @attributes[:tag_list] = @attributes[:tag_list].split(',').map(&:strip)
      end

      @changed ||= (association_changed?(:category_ids) || association_changed?(:tags))
      @issue.attributes = @attributes
      @changed ||= @issue.changed?

      status_change = @issue.changes[:status]

      if status_change && status_change.last == 'published'
        assert_publish_allowed

        if @issue.published_at.nil?
          @issue.published_at = Time.now
        end
      end
    end

    def update_meta
      return unless @changed

      @issue.updated_at = Time.now
      @issue.last_updated_by = @user
    end

    def update_or_create_promise_connection(promise_id, data)
      existing = PromiseConnection.where(promise_id: promise_id, issue_id: @issue.id).first
      status   = data.fetch(:status)

      if status == 'unrelated'
        if existing
          @issue.promise_connections.delete existing
          @changed = true
        end
      else
        if existing
          existing.status = status
          @changed ||= existing.changed?

          existing.save!
        else
          @issue.promise_connections.create!(status: status, promise_id: promise_id)
          @changed = true
        end
      end
    end

    def update_or_create_proposition_connection(proposition_id, connections)
      connections.each do |data|
        existing = PropositionConnection.where(proposition_id: proposition_id, issue_id: @issue.id, vote_id: data[:vote_id]).first

        if data[:connected]
          attrs = data.except(:connected).merge(proposition_id: proposition_id)

          # normalize '' vs nil
          attrs[:title]            = nil if attrs[:title].blank?
          attrs[:comment]          = nil if attrs[:comment].blank?

          if existing
            existing.attributes = attrs
            @changed ||= existing.changed?

            existing.save!
          else
            @issue.proposition_connections.create!(attrs)
            @changed = true
          end
        else
          if existing
            @issue.proposition_connections.delete existing
            @changed = true
          end
        end
      end
    end

    def update_or_create_or_destroy_party_comment(id, data)
      existing = PartyComment.find_by_issue_id_and_id(@issue.id, id)
      if data["deleted"]
        @changed = true
        existing.destroy
        return
      end

      if existing
        existing.attributes = data
        @changed ||= existing.changed?

        existing.save!
      else
        @issue.party_comments.create!(data.except(:id))
        @changed = true
      end
    end

    def update_or_create_or_destroy_position(id, data)
      existing = Position.find_by_issue_id_and_id(@issue.id, id)

      if data["deleted"]
        @changed = true
        existing.destroy
        return
      end

      if existing
        existing.attributes = data.except('parties')
        existing.parties = Party.find(data['parties'])
        @changed ||= existing.changed?

        existing.save!
      else
        new_position = @issue.positions.create(data.except('id', 'parties'))
        new_position.parties = Party.find(data['parties'])

        new_position.save!
        @changed = true
      end
    end

    def remove_deleted_comments
      @issue.party_comments.each do |existing|
        existing.destroy unless @party_comments && party_comments.keys.include?(existing.id)
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

    def save!
      @issue.save!
    end

    def assert_publish_allowed
      raise Unauthorized unless issue_policy.publish?
    end

    def assert_editing_allowed
      raise Unauthorized unless issue_policy.edit?
    end

    def issue_policy
      @issue_policy ||= IssuePolicy.new(@user, @issue)
    end

  end
end
