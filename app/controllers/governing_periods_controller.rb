class GoverningPeriodsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @coalition_parties = Party.select(&:in_gov?)
    @governing_periods = GoverningPeriod.all order: :start_date
  end

  def update
    save_governing_periods
    redirect_to :index
  end

  def destroy
    GoverningPeriod.find(params[:id]).destroy
    redirect_to :index
  end

  private

  def save_governing_periods
    governin_periods_params = params[:governing_periods]
    governin_periods_params.each do |id,params|
      governing_period = GoverningPeriod.find id
      unless governing_period.update_attributes(params)
        flash.alert = governing_period.errors.full_messages.join(' ')
      end
    end
  end

end
