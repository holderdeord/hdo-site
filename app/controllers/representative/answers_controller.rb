class Representative::AnswersController < RepresentativeController
  def create
    @answer = Answer.new(params[:answer])
    if @answer.save
      redirect_to representative_question_path(@answer.question), notice: t('app.answers.edit.created')
    else
      redirect_to representative_question_path(@answer.question, answer: @answer)
    end
  end
end