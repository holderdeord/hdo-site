class QuestionPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user, @record = user, record
  end

  def moderate?
    user.role == 'superadmin'
  end

end

