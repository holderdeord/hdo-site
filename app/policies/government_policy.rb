class GovernmentPolicy
  def initialize(government, record = nil)
    @government, @record = government, record
  end

  def create?
    @government.admin? || @government.superadmin?
  end

  alias_method :edit?,    :create?
  alias_method :update?,  :create?
  alias_method :destroy?, :create?
  alias_method :new?,     :create?
end