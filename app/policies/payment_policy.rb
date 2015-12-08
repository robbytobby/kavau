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
    return false if credit_agreement_or_year_terminated?
    user.admin? || user.accountant?
  end

  def destroy?
    update?
  end

  def permitted_params
    [:amount, :type, :date]
  end
end
