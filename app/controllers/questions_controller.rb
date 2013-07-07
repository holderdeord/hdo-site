class QuestionsController < ApplicationController
  before_filter { assert_feature(:questions) }
  before_filter :redirect_unless_answers_enabled, only: [:index, :show]
  before_filter :require_edit, only: [:new, :create]
  skip_before_filter :verify_authenticity_token, only: :create

  hdo_caches_page :index, :new

  DEFAULT_PER_PAGE = 20

  def index
    questions = Question.approved

    answered = questions.with_approved_answers

    if AppConfig.ignore_our_questions
      unanswered = questions.not_ours.without_approved_answers
    else
      unanswered = questions.without_approved_answers
    end

    @questions = {
      answered:   QuestionsDecorator.new(answered.order(:updated_at).first(6)),
      unanswered: QuestionsDecorator.new(unanswered.order(:updated_at).first(6))
    }

    @totals = {
      answered:   answered.count,
      unanswered: unanswered.count
    }
  end

  def all
    case params[:category]
    when 'answered'
      @questions = QuestionsDecorator.new(Question.approved.with_approved_answers.order(:updated_at).paginate(page: params[:page], per_page: params[:per_page] || DEFAULT_PER_PAGE))
    when 'unanswered'
      if AppConfig.ignore_our_questions
        @questions = QuestionsDecorator.new(Question.approved.not_ours.without_approved_answers.paginate(page: params[:page], per_page: params[:per_page] || DEFAULT_PER_PAGE))
      else
        unanswered = QuestionsDecorator.new(Question.approved.without_approved_answers.paginate(page: params[:page], per_page: params[:per_page] || DEFAULT_PER_PAGE))
      end
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

  def redirect_unless_answers_enabled
    redirect_to new_question_path unless AppConfig["answers_enabled"]
  end
end
