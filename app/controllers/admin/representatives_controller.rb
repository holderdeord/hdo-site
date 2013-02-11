class Admin::RepresentativesController < AdminController
  EDITABLE_ATTRIBUTES = [:twitter_id, :email]

  before_filter :fetch_representative, only: [:edit, :update]

  def index
    @representatives = Representative.order(:external_id)
  end

  def edit
  end

  def update
    attrs = params[:representative].slice(*EDITABLE_ATTRIBUTES)

    attrs.each do |k,v|
      attrs[k] = nil if v.blank?
    end

    if @representative.update_attributes(attrs)
      redirect_to admin_representatives_path, notice: t('app.updated.representative')
    else
      redirect_to edit_admin_representative_path(@representative), alert: @representative.errors.full_messages.to_sentence
    end
  end

  private

  def fetch_representative
    @representative = Representative.find(params[:id])
  end
end
