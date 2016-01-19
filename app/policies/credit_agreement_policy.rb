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
    @record.payments.none?
  end

  def permitted_params
    [:amount, :interest_rate, :cancellation_period, :account_id, :terminated_at, :number, :valid_from]
  end

  def download?
    return false unless user.admin? || user.accountant?
    true
  end

  def download_csv?
    download?
  end
end
