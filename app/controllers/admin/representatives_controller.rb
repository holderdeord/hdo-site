class Admin::RepresentativesController < ApplicationController

  def index
    reps = Representative.order(:last_name)
    @reps_grouped = reps.group_by { |r| r.last_name[0]}
  end

  def show
    @representative = Representative.find(params[:id])
  end

  def update
    @representative = Representative.find(params[:id])
    if @representative.update_attributes(params[:representative].slice(:twitter_id))
      flash.now[:success] = "Informasjonen er oppdatert."
      render:action => 'show'
    else
      flash.now[:error] = "Informasjonen ble ikke oppdatert."
      redirect_to :action => 'show'
    end
  end
end
