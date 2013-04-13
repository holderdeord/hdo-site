class Admin::RepresentativesController < AdminController
  EDITABLE_ATTRIBUTES = [:twitter_id, :email]

  before_filter :fetch_representative, except: [:index]
  before_filter :authorize_user, except: [:index]

  def index
    @representatives = Representative.order(:external_id)
  end

  def edit
  end

  def update
    attrs = params[:representative].slice(*EDITABLE_ATTRIBUTES)
    normalize_blanks(attrs)

    if @representative.update_attributes(attrs)
      redirect_to admin_representatives_path, notice: t('app.updated.representative')
    else
      redirect_to edit_admin_representative_path(@representative), alert: @representative.errors.full_messages.to_sentence
    end
  end

  def activate
    with_representative do
      @representative.send_confirmation_instructions
      redirect_to admin_representatives_path, notice: t('app.questions_and_answers.representative.confirmation_mail_sent', name: @representative.name)
    end
  end

  def reset_password
    with_representative do
      @representative.send_reset_password_instructions
      redirect_to admin_representatives_path, notice: t('app.questions_and_answers.representative.passwd_reset_mail_sent', name: @representative.name)
    end
  end

  private

  def authorize_user
    unless policy(@representative).edit?
      redirect_to admin_representatives_path, alert: t('app.errors.unauthorized')
      return
    end
  end

  def fetch_representative
    @representative = Representative.find(params[:id] || params[:representative_id])
  end

  def with_representative(&block)
    if @representative
      yield
    else
      redirect_to admin_representatives_path, alert: t('app.questions_and_answers.representative.not_found')
    end
  end
end
