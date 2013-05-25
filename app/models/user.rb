class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable,
         :rememberable,
         :trackable,
         :validatable
  attr_accessor :login

  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :role, :description, :active, :board, :title

  has_many :last_updated_issues, foreign_key: 'last_updated_by_id', class_name: 'Issue'
  has_many :issues, foreign_key: 'editor_id', order: :title

  ROLES = %w[contributor admin superadmin]
  validates :role, presence: true, inclusion: { in: ROLES }

  def admin?
    role == 'admin'
  end

  def superadmin?
    role == 'superadmin'
  end

  def first_name
    name.split(' ').first
  end

  def percentage_of_issues
    if Issue.count.zero?
      0
    else
      issues.size * 100 / Issue.count
    end
  end

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end
end
