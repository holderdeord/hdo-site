class Admin::UsersController < AdminController
  before_filter :fetch_user, only: [:show, :edit, :update, :destroy]
  before_filter :add_abilities

  helper_method :can_edit?

  def index
    @users = User.order(:updated_at).reverse_order
  end

  def show
  end

  def new
    @user = User.new

    unless can_edit?
      redirect_to admin_users_path, alert: t('app.errors.unauthorized')
      return
    end

    render action: 'new'
  end

  def edit
    unless can_edit?
      redirect_to admin_users_path, alert: t('app.errors.unauthorized')
      return
    end

    render action: 'edit'
  end

  def create
    @user = User.new(params[:user])

    unless can_edit?
      redirect_to admin_users_path, alert: t('app.errors.unauthorized')
      return
    end

    if @user.save
      redirect_to admin_user_path(@user), notice: t('app.users.edit.created')
    else
      render action: 'new'
    end
  end

  def update
    unless can_edit?
      redirect_to admin_users_path, alert: t('app.errors.unauthorized')
      return
    end

    attrs = params[:user]

    # allow editing user without changing password
    [:password, :password_confirmation].each do |attr|
      if attrs.include?(attr) && attrs[attr].blank?
        attrs.delete(attr)
      end
    end

    if @user.update_attributes(attrs)
      redirect_to admin_user_path(@user), notice: t('app.users.edit.updated')
    else
      render action: "edit"
    end
  end

  def destroy
    unless can_edit?
      redirect_to admin_users_path, alert: t('app.errors.unauthorized')
      return
    end

    @user.destroy
    redirect_to admin_users_path
  end

  private

  def fetch_user
    @user = User.find(params[:id])
  end

  def add_abilities
    abilities << User
  end

  def can_edit?
    can?(current_user, :edit, User)
  end
end
