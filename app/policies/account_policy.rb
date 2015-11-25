class AccountPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      (user.admin? || user.accountant?) ? scope : scope.project_accounts
    end
  end

  def destroy?
    return false unless user.admin? || user.accountant?
    return false if @record.credit_agreements.any?
    true
  end

  def permitted_params
    [:bic, :iban, :bank, :name, :owner, :default]
  end
end
