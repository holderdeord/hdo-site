class QuestionsController < ApplicationController
  before_filter { assert_feature(:questions) }

  def index
    @questions = Question.all # TODO: Question.published

    respond_to do |format|
      format.html
      format.json { render json: @questions }
    end
  end

  def show
    @question = Question.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @question }
    end
  end

  def new
    @question = Question.new

    respond_to do |format|
      format.html
      format.json { render json: @question }
    end
  end

  def create
    @question = Question.new(normalize_blanks(params[:question]))

    respond_to do |format|
      if @question.save
        format.html { redirect_to @question, notice: t('app.questions.edit.created') }
        format.json { render json: @question, status: :created, location: @question }
      else
        format.html { render action: "new" }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end
end
