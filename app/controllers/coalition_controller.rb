class CoalitionController < ApplicationController

  def index
    @coalition_parties = Party.select(&:in_gov?)
    @governing_periods = GoverningPeriod.all order: :start_date
  end

  def update
    save_governing_periods
    redirect_to view_coalition_path
  end

  private

  def save_governing_periods
    governin_periods_params = params[:governing_periods]
    governin_periods_params.each do |id,params|
      governing_period = GoverningPeriod.find id
      governing_period.update_attributes(params)
    end
  end

end
