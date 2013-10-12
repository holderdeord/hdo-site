# encoding: utf-8

module Admin::IssuesHelper

  def editor_options_for(issue)
    users = User.order(:name)

    editor = issue.new_record? ? current_user : issue.editor

    options_from_collection_for_select(users, 'id', 'name', selected: editor.try(:id))
  end

  def proposition_type_options_for(connection)
    types  = I18n.t('app.votes.proposition_types').except(:none)
    sorted = types.invert.sort_by { |human_name, key| human_name }

    sorted.unshift [I18n.t!("app.votes.proposition_types.none"), nil]

    options_for_select sorted, (connection && connection.proposition_type)
  end

  def all_tags
    ActsAsTaggableOn::Tag.select(:name).all.map(&:name)
  end

  def connected_issues_for(vote)
    (vote.issues - [@issue]).first(3)
  end

  def promise_status_for(promise)
    conn = promise.promise_connections.find { |pc| pc.issue_id == @issue.id }
    conn ? conn.status : 'unrelated'
  end

  def promise_states
    [PromiseConnection::STATES, PromiseConnection::UNRELATED_STATE].flatten
  end

  def disable_promise_state?(state, promise)
    promise.parliament_period_name != '2009-2013' && %[kept partially_kept broken].include?(state)
  end

  def issues_for_promise(promise)
    pcs = promise.promise_connections.select { |pc| pc.issue.id != @issue.id }

    out = ''

    if pcs.any?
      out = "#{I18n.t 'app.issues.edit.promise_used_in'} "
      out << pcs.map { |pc| link_to(pc.issue.title, pc.issue, target: '_blank') }.to_sentence
    end

    out.html_safe
  end

  def promise_counts_for(party)
    pcs = @promise_connections.select { |e| e.promise.parties.include?(party) }

    counts = Hash.new(0).with_indifferent_access
    counts[:total] = pcs.size
    counts[:used]  = 0

    pcs.each do |pc|
      counts[:used] += 1 if pc.status != 'related'
      counts[pc.status.to_sym] += 1
    end

    counts
  end

  def with_promise_status(promises)
    promises.sort_by(&:parliament_period_name).map { |pr| [pr, promise_status_for(pr)] }.sort_by { |_, status| status }
  end

  def party_options(opts = {})
    options_for_select(Party.all.reduce({}) { |options, party| options[party.name] = party.id; options }, opts[:selected])
  end
end