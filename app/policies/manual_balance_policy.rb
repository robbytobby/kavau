class ManualBalancePolicy < BalancePolicy
  def index?
    false
  end

  def destroy?
    # TODO forbid destroy if balance has been sent to creditor
    return false if record.credit_agreement.terminated?
    user.admin? || user.accountant?
  end
end

