class UserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      user.admin? ? scope.all : scope.none
    end
  end

  def index?
    user.admin? 
  end

  def show?
    user.admin?
  end

  def create?
    user.admin?
  end

  def update?
    record.id == user.id || user.admin? 
  end

  def destroy?
    user.admin? 
  end

  def permitted_params
    [:login, :role, :password, :password_confirmation, :first_name, :name, :email, :phone]
  end
end
