class RepresentativePolicy
  def initialize(user, record = nil)
    @user, @record = user, record
  end

  def edit?
    @user && @user.superadmin?
  end

  alias_method :update?,  :edit?
end