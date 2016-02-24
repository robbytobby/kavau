class SettingPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      user.admin? ? Setting.all : Setting.none
    end
  end

  def index?
    user.admin?
  end

  def show?
    user.admin?
  end

  def new?
    false
  end
  
  def create?
    new?
  end

  def edit?
    user.admin?
  end

  def update?
    user.admin?
  end

  def destroy?
    user.admin?
  end

  def permitted_params
    [:value]
  end
end
