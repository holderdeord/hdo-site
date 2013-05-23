class QuestionPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user, @record = user, record
  end

  def moderate?
    user.superadmin?
  end

end

