module Hdo
  class IssueEditSteps
    STEPS = %w[categories votes promises party_comments positions]

    def initialize(params, session)
      @params  = params
      @session = session
    end

    def from_param!
      @session[:issue_step] = from_param
    end

    def from_param
      @params[:step]
    end

    def first!
      @session[:issue_step] = first
    end

    def next!
      unless save?
        @session[:issue_step] = next_step
      end
    end

    def clear!
      @session.delete :issue_step
    end

    def first
      STEPS.first
    end

    def all
      STEPS
    end

    def current
      @session[:issue_step] ||= first
    end

    def after(step = STEPS.first)
      STEPS[STEPS.index(step) + 1]
    end

    def before(step)
      STEPS[STEPS.index(step) - 1]
    end

    def first?(step)
      step == STEPS.first
    end

    def last?(step)
      step == STEPS.last
    end

    def finish?
      !!@params[:finish]
    end

    def save?
      !!@params[:save]
    end

    private

    def next_step
      if @params[:next_step] && STEPS.include?(@params[:next_step])
        @params[:next_step]
      elsif @params[:previous]
        before(current)
      else
        after(current)
      end
    end
  end
end