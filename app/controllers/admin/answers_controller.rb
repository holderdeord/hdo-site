class Admin::AnswersController < AdminController
  before_filter { assert_feature(:questions) }

  before_filter :fetch_question
  before_filter :fetch_answer, only: [:edit, :update, :destroy, :approve, :reject]

  def index
    @answers_by_status = Answer.all_by_status
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
      redirect_to admin_question_answers_path(@question), notice: t('app.answers.edit.updated')
    else
      render action: "edit"
    end
  end

  def destroy
    @answer.destroy

    redirect_to admin_question_answers_url(@question)
  end

  def reject
    @answer.reject
    save_answer
  end

  def approve
    @answer.approve
    save_answer
  end

  private

  def fetch_question
    @question = Question.find(params[:question_id])
  end

  def fetch_answer
    @answer = Answer.find(params[:id])
  end

  def save_answer
    if @answer.save
      redirect_to admin_question_answers_url(@question), notice: t('app.answers.moderate.approved')
    else
      redirect_to admin_question_answers_url(@question), alert: @answer.errors.full_messages.to_sentence
    end
  end
end
