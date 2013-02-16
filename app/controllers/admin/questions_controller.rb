class Admin::QuestionsController < AdminController
  before_filter { assert_feature(:questions) }
  before_filter :fetch_question, except: :index

  def index
    @questions_by_status = Question.all_by_status
  end

  def edit
  end

  def approve
    @question.status = 'approved'
    save_question
  end

  def reject
    @question.status = 'rejected'
    save_question
  end

  def destroy
    @question.destroy

    redirect_to admin_questions_path
  end

  private

  def fetch_question
    @question = Question.find(params[:id])
  end

  def save_question
    if @question.save
      redirect_to admin_questions_path, notice: t('app.questions.edit.updated')
    else
      redirect_to admin_questions_path, alert: @question.errors.full_messages.to_sentence
    end
  end
end
