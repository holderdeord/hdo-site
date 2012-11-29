class UserPolicy
  def initialize(user, record = nil)
    @user, @record = user, record
  end

  def create?
    @user.superadmin?
  end

  alias_method :edit?,    :create?
  alias_method :update?,  :create?
  alias_method :destroy?, :create?
  alias_method :new?,     :create?
end