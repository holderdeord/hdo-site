class TopicsController < ApplicationController

  def show
    @topic        = Topic.find(params[:id])
    @issues       = @topic.issues.published
    @other_issues = Issue.published.reject { |e| e.topics.include? @topic }.shuffle.first(5)

    @previous_topic, @next_topic = @topic.previous_and_next(order: :name)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @topic }
    end
  end

end
