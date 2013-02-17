class Admin::AnswersController < AdminController
  before_filter { assert_feature(:questions) }

  before_filter :fetch_question
  before_filter :fetch_answer, only: [:edit, :update, :destroy]

  def index
    @answers = @question.answers
  end

  def new
    @answer = Answer.new
  end

  def edit
  end

  def create
    @answer = @question.answers.create(params[:answer])

    if @answer.save
      redirect_to admin_question_answers_path(@question), notice: t('app.answers.edit.created')
    else
      render action: "new"
    end
  end

  def update
    if @answer.update_attributes(params[:answer])
      redirect_to admin_question_answers_path(@question, @answer), notice: t('app.answers.edit.updated')
    else
      render action: "edit"
    end
  end

  def destroy
    @answer.destroy

    redirect_to admin_question_answers_url(@question)
  end

  private

  def fetch_question
    @question = Question.find(params[:question_id])
  end

  def fetch_answer
    @answer = Answer.find(params[:id])
  end
end
