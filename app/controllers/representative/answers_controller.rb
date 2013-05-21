class Representative::AnswersController < RepresentativeController
  def create
    question = Question.find(params[:answer][:question_id])
    @answer = question.answer =  Answer.new(params[:answer])
    if question.save
      redirect_to representative_root_path, notice: t('app.answers.edit.created')
    else
      if @answer.question
        redirect_to representative_question_path(@answer.question_id, answer: @answer), alert: @answer.errors.full_messages.to_sentence
      else
        redirect_to representative_root_path, alert: @answer.errors.full_messages.to_sentence
      end
    end
  end
end