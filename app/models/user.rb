class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :recoverable, :trackable, :validatable, :lockable, :timeoutable
  @valid_roles = ['user', 'admin', 'accountant']

  validates_presence_of :login, :first_name, :name, :email
  validates_presence_of :password, :password_confirmation, on: :create
  validate :password_strength
  validate :password_name_inclusions
  validates_inclusion_of :role, in:  @valid_roles

  def self.valid_roles
    @valid_roles
  end

  def user?
    has_role?(:user)
  end

  def admin?
    has_role?(:admin)
  end

  def accountant?
    has_role?(:accountant)
  end

  protected
    def has_role?(string)
      role == string.to_s 
    end

  private
    def password_strength
      if password.present? and not password.match(/^(?=.*[a-z])(?=.*[A-Z])(?=.*(\d|\W))./)
        errors.add :password, :to_week
      end
    end

    def password_name_inclusions
      if password.present? and password.match(/(#{first_name}|#{name}|#{login})/i)
        errors.add :password, :name_inclusion
      end
    end
end
