class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable,
         :rememberable,
         :trackable,
         :validatable

  attr_accessible :email, :password, :password_confirmation, :remember_me, :name

  has_many :last_updated_issues, foreign_key: 'last_updated_by_id', class_name: 'Issue'
  has_many :issues, foreign_key: 'editor_id'
end
