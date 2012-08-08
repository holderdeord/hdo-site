class GoverningPeriodsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @coalition_parties = Party.select(&:in_government?)
    @governing_periods = GoverningPeriod.all order: :start_date
  end

  def update
    save_governing_periods
    redirect_to governing_periods_url
  end

  def destroy
    GoverningPeriod.find(params[:id]).destroy
    redirect_to governing_periods_url
  end

  private

  def save_governing_periods
    governin_periods_params = params[:governing_periods]
    governin_periods_params.each do |id,params|
      id = nil if id.start_with? 'new'
      governing_period = GoverningPeriod.find_or_create_by_id id
      unless governing_period.update_attributes(params)
        flash.alert = governing_period.errors.full_messages.to_sentence
      end
    end
  end

end
