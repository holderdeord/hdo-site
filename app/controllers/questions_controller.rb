class QuestionsController < ApplicationController
  before_filter { assert_feature(:questions) }
  before_filter :redirect_unless_answers_enabled, only: [:index, :show]
  skip_before_filter :verify_authenticity_token, only: :create

  hdo_caches_page :index, :new

  DEFAULT_PER_PAGE = 20

  def index
    @questions = Question.approved
    @questions = @questions.answered_or_not_ours if AppConfig.ignore_our_questions
    @questions = @questions.order(:updated_at).paginate(page: params[:page], per_page: DEFAULT_PER_PAGE)
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
    @representatives = Rails.cache.fetch('question-form/representatives', expires_in: 1.day) do
      Representative.askable.includes(:district, party_memberships: :party).order(:last_name).to_a
    end

    @districts = Rails.cache.fetch('question-form/districts', expires_in: 1.day) do
      District.order(:name).to_a
    end
  end

  def redirect_unless_answers_enabled
    redirect_to new_question_path unless AppConfig["answers_enabled"]
  end
end
