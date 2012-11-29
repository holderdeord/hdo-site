class IssuePolicy
  attr_reader :user, :record

  class Scope
    attr_accessor :user, :scope

    def initialize(user, scope)
      @user, @scope = user, scope
    end

    def resolve
      if user
        scope
      else
        scope.published
      end
    end
  end

  def initialize(user, record)
    @user, @record = user, record
  end

  def show?
    record.published? || logged_in?
  end

  def change_status?
    logged_in? && user.superadmin?
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  private

  def logged_in?
    !!user
  end

end

