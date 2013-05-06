class QuestionsController < ApplicationController
  before_filter { assert_feature(:questions) }

  def index
    @questions = Question.approved
  end

  def show
    @question = Question.approved.find(params[:id])
  end

  def new
    @question = Question.new
  end

  def create
    question = normalize_blanks(params[:question])
    rep      = question.delete(:representative)

    @question = Question.new(question)
    @question.representative = Representative.find_by_slug(rep) if rep

    unless @question.save
      render action: "new"
    end
  end
end
