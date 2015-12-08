class ManualBalancePolicy < BalancePolicy
  def index?
    false
  end

  def destroy?
    return false if record.year_terminated?
    return false if record.credit_agreement.terminated?
    user.admin? || user.accountant?
  end
end

