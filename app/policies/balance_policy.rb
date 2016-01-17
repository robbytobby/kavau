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
    return false if credit_agreement_or_year_terminated?
    return false unless record.persisted?
    user.admin? || user.accountant?
  end

  def destroy?
    false
  end

  def download?
    return false unless user.admin? || user.accountant?
    true
  end

  def download_csv?
    download?
  end

  def permitted_params
    [:end_amount]
  end
end

