class QuestionsController < ApplicationController
  before_filter :require_edit, only: [:new, :create]
  skip_before_filter :verify_authenticity_token, only: :create

  hdo_caches_page :index, :new, :all

  DEFAULT_PER_PAGE = 20

  def index
    questions = Question.approved

    answered = questions.with_approved_answers.order('answers.created_at DESC')
    unanswered = questions.not_ours.without_approved_answers.order("updated_at DESC")

    @questions = {
      answered:   QuestionsDecorator.new(answered.first(6)),
      unanswered: QuestionsDecorator.new(unanswered.first(6))
    }

    @totals = {
      answered:   answered.count,
      unanswered: unanswered.count
    }
  end

  def all
    case params[:category]
    when 'answered'
      questions = Question.approved.with_approved_answers.order(:updated_at).page(params[:page]).per(params[:per_page] || DEFAULT_PER_PAGE)
      @questions = QuestionsDecorator.new(questions)
    when 'unanswered'
      questions = Question.approved.not_ours.without_approved_answers.page(params[:page]).per(params[:per_page] || DEFAULT_PER_PAGE)
      @questions = QuestionsDecorator.new(questions)
    else
      render_not_found
    end
  end

  def show
    @question = Question.approved.find(params[:id])

    if @question.answer.try(:approved?)
      @answer         = @question.answer
      @representative = @answer.representative
      @party          = @answer.party
    else
      @answer         = nil
      @representative = @question.representative
      @party          = @representative.party_at(@question.created_at)
    end
  end

  def new
    fetch_representatives_and_districts
    @question = Question.new
  end

  def create
    question = params[:question]
    rep      = question.delete(:representative)

    @question = Question.new(question)
    @question.representative = Representative.askable.find_by_slug(rep) if rep

    unless @question.save
      fetch_representatives_and_districts
      render action: "new"
    end
  end

  def conduct
    render '_conduct'
  end

  private

  def fetch_representatives_and_districts
    @representatives = Representative.potentially_askable.includes(:district, party_memberships: :party).order(:last_name).to_a
    @districts = District.order(:name).to_a
  end
end
