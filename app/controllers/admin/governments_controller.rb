class Admin::GovernmentsController < AdminController
  before_filter :fetch_government, only: [:edit, :update, :destroy]

  def index
    @governments = Government.order(:start_date).reverse_order
  end

  def new
    @government = Government.new

    if policy(@government).new?
      render action: 'new'
    else
      redirect_to admin_governments_path, alert: t('app.errors.unauthorized')
    end

  end

  def edit
    if policy(@government).edit?
      render action: 'edit'
    else
      redirect_to admin_governments_path, alert: t('app.errors.unauthorized')
    end
  end

  def create
    @government = Government.new(params[:government])

    if policy(@government).create?
      if @government.save
        redirect_to admin_governments_path, notice: t('app.created.government')
      else
        render action: 'new'
      end
    else
      redirect_to admin_governments_path, alert: t('app.errors.unauthorized')
    end
  end

  def update
    if policy(@government).update?
      if @government.update_attributes(params[:government])
        redirect_to admin_governments_path, notice: t('app.updated.government')
      else
        render action: 'edit'
      end
    else
      redirect_to admin_governments_path, alert: t('app.errors.unauthorized')
    end

    binding.pry
  end

  def destroy
    if policy(@government).destroy?
      @government.destroy
      redirect_to admin_governments_path
    else
      redirect_to admin_governments_path, alert: t('app.errors.unauthorized')
    end
  end

  private

  def fetch_government
    @government = Government.find(params[:id])
  end
end
