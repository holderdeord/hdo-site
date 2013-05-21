class RepresentativeController < ApplicationController
  layout 'logged_in'
  before_filter :authenticate_representative!

  def index
    @questions = Question.approved.where("representative_id = ?", current_representative)
  end

  def show_question
    @question = Question.approved.find(params[:id])
    @answer = Answer.new(question: @question, representative: @question.representative)
  end

  def create_answer
    question = Question.find(params[:question_id])
    @answer = question.create_answer(params[:answer])
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