class PaymentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.admin? || user.accountant?
  end

  def update?
    user.admin? || user.accountant?
  end

  def destroy?
    user.admin? || user.accountant?
  end

  def permitted_params
    [:amount, :type, :date]
  end
end
