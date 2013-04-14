class QuestionsController < ApplicationController
  before_filter { assert_feature(:questions) }

  def index
    @questions = Question.approved
  end

  def show
    @question = Question.find(params[:id])
    # TODO: render_not_found unless @question.approved?
  end

  def new
    @question = Question.new
  end

  def create
    question = normalize_blanks(params[:question])
    rep      = question.delete(:representative)

    @question = Question.new(question)
    @question.representative = Representative.find(rep) if rep

    if @question.save
      # TODO: show action should not be available unless status=approved
      redirect_to @question, notice: t('app.questions.edit.created')
    else
      render action: "new"
    end
  end
end
