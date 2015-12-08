class PaymentPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    return false if record.credit_agreement.terminated?
    user.admin? || user.accountant?
  end

  def update?
    return false if record.year_terminated?
    return false if record.credit_agreement.terminated?
    user.admin? || user.accountant?
  end

  def destroy?
    return false if record.year_terminated?
    return false if record.credit_agreement.terminated?
    user.admin? || user.accountant?
  end

  def permitted_params
    [:amount, :type, :date]
  end
end
