# encoding: UTF-8

class IssuesController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :votes]
  before_filter :fetch_issue, :only => [:show, :edit, :update, :destroy, :votes, :votes_search]

  helper_method :edit_steps

  def index
    @issues = Issue.order(:title).sort_by { |i| [i.published? ? 1 : 0, i.title] }

    respond_to do |format|
      format.html
      format.json { render json: @issues }
    end
  end

  def show
    # introduce a policy object?
    if @issue.published? || user_signed_in?
      assign_promises_by_party
      assign_party_groups
      assign_previous_and_next_issues

      respond_to do |format|
        format.html
        format.json { render json: @issue }
      end
    else
      redirect_to new_user_session_path
    end
  end

  def new
    @issue = Issue.new
    fetch_categories

    edit_steps.first!

    respond_to do |format|
      format.html
      format.json { render json: @issue }
    end
  end

  def edit
    if edit_steps.from_param
      assign_disable_buttons
      assign_issue_steps

      step = edit_steps.from_param!
      send "edit_#{step}"
    else
      redirect_to edit_issue_step_url(@issue, :step => edit_steps.first)
    end
  end

  def create
    @issue = Issue.new(params[:issue])
    @issue.last_updated_by = current_user

    if @issue.save
      if edit_steps.finish?
        redirect_to @issue
      else
        redirect_to edit_issue_step_url(@issue, :step => edit_steps.after)
      end
    else
      flash.alert = @issue.errors.full_messages.to_sentence
      fetch_categories

      render :action => :new
    end
  end

  def update
    if @issue.update_attributes_and_votes_for_user(params[:issue], params[:votes], current_user)
      edit_steps.next!

      if edit_steps.finish?
        session.delete :issue_step
        redirect_to @issue
      else
        redirect_to edit_issue_step_url(@issue, step: edit_steps.current)
      end
    else
      flash.alert = @issue.errors.full_messages.to_sentence
      redirect_to edit_issue_step_url(@issue, :step => edit_steps.current)
    end
  end

  def destroy
    @issue.destroy

    respond_to do |format|
      format.html { redirect_to issues_url }
      format.json { head :no_content }
    end
  end

  def votes
    if @issue.published? || user_signed_in?
      assign_party_groups

      connections = @issue.vote_connections
      @issue_votes = connections.map do |connection|
        Hdo::Views::IssueVote.new(connection, @party_groups)
      end

      @issue_votes = @issue_votes.sort_by { |e| e.time }.reverse
    else
      redirect_to new_user_session_path
    end
  end

  def votes_search
    votes = Vote.naive_search(
      params[:filter],
      params[:keyword],
      @issue.categories
    )

    # remove already connected votes
    votes -= @issue.vote_connections.map { |e| e.vote }

    # TODO: cleanup
    by_issue_type = Hash.new { |hash, issue_type| hash[issue_type] = Set.new }
    votes.each do |vote|
      vote.parliament_issues.each do |issue|
        by_issue_type[issue.issue_type] << vote
      end
    end

    render partial: 'votes_search_result', locals: { votes_by_issue_type: by_issue_type }
  end

  private

  def assign_previous_and_next_issues
    @previous_issue, @next_issue = @issue.previous_and_next(published_only: !user_signed_in?)
  end

  def assign_party_groups
    @party_groups = Party.governing_groups
  end

  def edit_categories
    fetch_categories
  end

  def edit_promises
    # TODO: confusing that we use @promises_by_party in both
    # issue#edit and issue#show, but as wildly different data structures.
    @promises_by_party = @issue.categories.includes(:promises).map(&:promises).compact.flatten.uniq.group_by { |e| e.short_party_names }
  end

  def assign_promises_by_party
    # {
    #   'A'    => { 'I partiprogrammet har...' => promises, 'I regjeringserklæring har...' => promises },
    #   'FrP'  => { 'I partiprogrammet har...' => promises },
    # }

    @promises_by_party = {}

    @issue.promises.each do |promise|
      promise.parties.each do |party|
        data = @promises_by_party[party] ||= {}
        (data[promise.source_header] ||= []) << promise
      end
    end
  end

  def edit_votes
    @votes_and_connections = @issue.vote_connections.map { |e| [e.vote, e] }
  end

  def edit_topics
    @topics = Topic.all
  end

  def fetch_categories
    @categories = Category.column_groups
  end

  def fetch_issue
    @issue = Issue.find(params[:id])
  end

  def assign_issue_steps
    @issue_steps = Hdo::IssueEditSteps::STEPS
  end

  def assign_disable_buttons
    @disable_next = edit_steps.last?(params[:step]) or @issue && @issue.new_record?
    @disable_prev = edit_steps.first?(params[:step])
  end

  def edit_steps
    @edit_steps ||= Hdo::IssueEditSteps.new(params, session)
  end

end
