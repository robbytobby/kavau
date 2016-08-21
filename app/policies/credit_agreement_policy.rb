class CreditAgreementPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def index?
    true
  end

  def destroy?
    return false unless user.admin? || user.accountant?
    record.payments.none?
  end

  def permitted_params
    [:amount, :cancellation_period, :number, :terminated_at] + payment_dependent_params
  end

  def download?
    return false unless user.admin? || user.accountant?
    true
  end

  private
  def payment_dependent_params
    return [:account_id, :interest_rate, :valid_from] if record.payments.none? || user.admin?
    []
  end
end
