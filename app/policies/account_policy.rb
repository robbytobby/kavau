class AccountPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      (user.admin? || user.accountant?) ? scope.all : scope.project_accounts
    end
  end

  def index?
    user.admin? || user.accountant?
  end

  def show?
    user.admin? || user.accountant?
  end

  def create?
    user.admin? || user.accountant?
  end

  def update?
    user.admin? || user.accountant?
  end

  def destroy?
    return false unless user.admin? || user.accountant?
    return false if @record.credit_agreements.any?
    true
  end

  def permitted_params
    [:bic, :iban, :bank, :name, :owner]
  end
end

