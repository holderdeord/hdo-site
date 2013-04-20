class Representative::AnswersController < RepresentativeController
  def create
    @answer = Answer.new(params[:answer])
    if @answer.save
      redirect_to representative_question_path(@answer.question), notice: t('app.answers.edit.created')
    else
      if @answer.question
        redirect_to representative_question_path(@answer.question_id, answer: @answer), alert: @answer.errors.full_messages.to_sentence
      else
        redirect_to representative_root_path, alert: @answer.errors.full_messages.to_sentence
      end
    end
  end
end