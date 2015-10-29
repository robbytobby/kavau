class UserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      user.admin? ? scope : scope.none
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
    role_independent_params + role_dependent_params
  end

  def role_independent_params
    [:login, :password, :password_confirmation,
     :first_name, :name, :email, :phone]
  end

  def role_dependent_params
    user.admin? ? [:role] : []
  end
end
