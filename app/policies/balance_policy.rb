class BalancePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def index?
    user.admin? || user.accountant?
  end

  def show?
    return false unless record.persisted?
    user.admin? || user.accountant?
  end

  def create?
    user.admin? || user.accountant?
  end
  
  def update?
    return false unless record.persisted?
    user.admin? || user.accountant?
  end

  def permitted_params
    [:end_amount]
  end
end

