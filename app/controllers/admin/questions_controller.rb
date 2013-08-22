class Admin::QuestionsController < AdminController
  before_filter :fetch_question, except: :index
  before_filter :assert_moderator, except: :index
  before_filter :require_edit, except: :index

  STATUSES = [
    :pending,
    :answer_pending,
    :approved,
    :rejected,
    :answer_rejected,
    :unanswered
  ].freeze

  def index
    @questions_by_status = {
      pending:         Question.pending,
      answer_pending:  Question.with_pending_answers,
      approved:        Question.answered.where('answers.status = ?', 'approved'),
      rejected:        Question.rejected,
      answer_rejected: Question.answered.where('answers.status = ?', 'rejected'),
      unanswered:      Question.not_ours.approved.unanswered
    }

    @active_tab = if @questions_by_status[:answer_pending].any?
      :answer_pending
    elsif @questions_by_status[:pending].any?
      :pending
    else
      :approved
    end

    @show_edit = policy(Question).moderate?
  end

  def edit
    @answer = @question.answer
  end

  def update
    issue_ids = params[:question][:issues].reject(&:blank?) if params[:question][:issues]

    @question.issues = Issue.find(issue_ids || [])
    @question.status = params[:question][:status]

    question_attributes = params[:question].slice(:internal_comment, :body, :from_name, :show_sender)

    @question.update_attributes(question_attributes)

    if @question && @question.answer
      @question.answer.update_attributes(params[:question][:answer]) if params[:question][:answer]
      @question.answer.update_attributes(body: params[:question][:answer_body])
    end

    if @question.save
      redirect_to edit_admin_question_path(@question), notice: t('app.questions.edit.updated')
    else
      redirect_to edit_admin_question_path(@question), alert: @question.errors.full_messages.to_sentence
    end
  end

  def create_answer
    @question.create_answer!(representative: @question.representative, body: '-')
    redirect_to edit_admin_question_path(@question), notice: 'Opprettet'
  end

  def question_approved_email_rep
    if !@question.representative.confirmed? && @question.representative.confirmation_token.nil?
      redirect_to edit_admin_question_path(@question), alert: t('app.questions.edit.rep_not_invited')
    elsif !@question.approved?
      redirect_to edit_admin_question_path(@question), alert: t('app.questions.edit.question_not_approved')
    else
      ModerationMailer.question_approved_representative_email(@question).deliver
      redirect_to edit_admin_question_path(@question), notice: t('app.questions.edit.email_sent', email: @question.representative.email)
    end
  end

  def question_approved_email_user
    unless @question.approved?
      redirect_to edit_admin_question_path(@question), alert: t('app.questions.edit.question_not_approved')
    else
      ModerationMailer.question_approved_user_email(@question).deliver
      redirect_to edit_admin_question_path(@question), notice: t('app.questions.edit.email_sent', email: @question.from_email)
    end
  end

  def question_rejected_email_user
    if @question.rejected?
      if params[:reason].blank?
        redirect_to edit_admin_question_path(@question), alert: t('app.questions.edit.no_reject_reason')
      else
        @question.update_attributes(rejection_reason: params[:reason])
        if @question.save
          ModerationMailer.question_rejected_user_email(@question).deliver
          redirect_to edit_admin_question_path(@question), notice: t('app.questions.edit.email_sent', email: @question.from_email)
        else
          redirect_to edit_admin_question_path(@question), alert: @question.errors.full_messages.to_sentence
        end
      end
    else
      redirect_to edit_admin_question_path(@question), alert: t('app.questions.edit.question_not_rejected')
    end
  end

  def answer_approved_email_user
    unless @question.has_approved_answer?
      redirect_to edit_admin_question_path(@question), alert: t('app.questions.edit.answer_not_approved')
    else
      ModerationMailer.answer_approved_user_email(@question).deliver
      redirect_to edit_admin_question_path(@question), notice: t('app.questions.edit.email_sent', email: @question.from_email)
    end
  end

  private

  def fetch_question
    @question = Question.find(params[:id])
  end

  def assert_moderator
    authorize @question, :moderate?
  end
end
