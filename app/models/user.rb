class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :recoverable, :trackable, :validatable, :lockable, :timeoutable

  validates_presence_of :login, :first_name, :name, :email
  validates_presence_of :password, :password_confirmation, on: :create
end
