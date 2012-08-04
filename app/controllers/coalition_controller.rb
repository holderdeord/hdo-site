class CoalitionController < ApplicationController

  def index
    @coalition_parties = Party.select(&:in_gov?)
    @governing_periods = GoverningPeriod.all order: :start_date
  end

  def update
    redirect_to view_coalition_path
  end

end
