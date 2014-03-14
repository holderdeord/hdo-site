# encoding: utf-8

module Admin::IssuesHelper

  def issue_options_for(model)
    # TODO(jari): this can be done with .pluck([:title, :id]) in rails 4
    opts = Issue.published.order(:title).select([:title, :id]).map { |e| [e.title, e.id] }
    options_for_select opts, selected: model.issues.map(&:id)
  end

  def proposer_options_for(model)
    proposers = Rails.cache.fetch('admin/propositions/proposers', expires_in: 1.day) do
      reps = Representative.all.map { |e| ["#{e.full_name} - #{e.external_id}", "#{e.class}-#{e.id}"]  }
      party = Party.all.map { |e| ["#{e.name} - #{e.external_id}", "#{e.class}-#{e.id}"] }

      party + reps
    end

      selected = model.proposers.map { |e| "#{e.class}-#{e.id}" }

    options_for_select proposers, selected: selected
  end

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

  def connected_issues_for(proposition)
    (proposition.issues - [@issue])
  end

  def promise_status_for(promise)
    conn = promise.promise_connections.find { |pc| pc.issue_id == @issue.id }
    conn ? conn.status : 'unrelated'
  end

  def parliament_period_options_for(position)
    data = ParliamentPeriod.order(:start_date).reverse_order.map { |e| [e.name, e.id] }

    options_for_select data, selected: position.parliament_period.try(:id)
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
    counts[:used] = 0

    pcs.each do |pc|
      counts[:used] += 1
      counts[pc.status.to_sym] += 1
    end

    counts
  end

  def with_promise_status(promises)
    promises.sort_by(&:parliament_period_name).map { |pr| [pr, promise_status_for(pr)] }.sort_by { |_, status| status }
  end

  def party_options(opts = {})
    options_for_select(Party.order(:name).map { |p| [p.name, p.id] }, opts[:selected])
  end

  def parliament_period_options(opts = {})
    options_for_select(ParliamentPeriod.order(:start_date).reverse_order.map { |p| [p.name, p.id] }, opts[:selected])
  end
end
