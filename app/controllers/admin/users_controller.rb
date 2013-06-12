class Admin::UsersController < AdminController
  before_filter :fetch_user, only: [:show, :edit, :update, :destroy]
  before_filter :require_edit, except: [:index, :show]

  def index
    @users = User.order(:name).all
  end

  def show
  end

  def new
    @user = User.new

    unless policy(@user).new?
      redirect_to admin_users_path, alert: t('app.errors.unauthorized')
      return
    end

    render action: 'new'
  end

  def edit
    unless policy(@user).edit?
      redirect_to admin_users_path, alert: t('app.errors.unauthorized')
      return
    end

    render action: 'edit'
  end

  def create
    @user = User.new(params[:user])

    unless policy(@user).create?
      redirect_to admin_users_path, alert: t('app.errors.unauthorized')
      return
    end

    if @user.save
      redirect_to admin_user_path(@user), notice: t('app.created.user')
    else
      render action: 'new'
    end
  end

  def update
    unless policy(@user).update?
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
      redirect_to admin_user_path(@user), notice: t('app.updated.user')
    else
      render action: "edit"
    end
  end

  def destroy
    unless policy(@user).destroy?
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
end
