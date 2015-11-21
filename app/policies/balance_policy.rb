class BalancePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def index?
    user.admin? || user.accountant?
  end

  def new?
    false
  end

  def show?
    false
  end

  def create?
    false
    #user.admin? || user.accountant?
  end
  
  def update?
    return false if record.credit_agreement.terminated?
    return false unless record.persisted?
    user.admin? || user.accountant?
  end

  def permitted_params
    [:end_amount]
  end
end

