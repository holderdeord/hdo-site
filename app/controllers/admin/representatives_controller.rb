class Admin::RepresentativesController < AdminController

  def index
    reps = Representative.order(:last_name)
    @reps_grouped = reps.group_by { |r| r.last_name[0]}
  end

  def show
    @representative = Representative.find(params[:id])
  end

  def update
    @representative = Representative.find(params[:id])
    twitter_handle = params[:representative].slice(:twitter_id)

    if twitter_handle.values == [""]
      @representative.update_attributes(:twitter_id => nil)
      render:action => 'show'
    elsif @representative.update_attributes(twitter_handle)
      flash.now[:success] = "Informasjonen er oppdatert."
      render:action => 'show'
    else
      flash.now[:error] = "Informasjonen ble ikke oppdatert."
      redirect_to :action => 'show'
    end
  end
end
