class BalancePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def new?
    false
  end

  def create?
    false
  end
  
  def update?
    return false if record.year_terminated?
    return false if record.credit_agreement.terminated?
    return false unless record.persisted?
    user.admin? || user.accountant?
  end

  def destroy?
    false
  end

  def permitted_params
    [:end_amount]
  end
end

