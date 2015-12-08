class ManualBalancePolicy < BalancePolicy
  def index?
    false
  end

  def destroy?
    return false if credit_agreement_or_year_terminated?
    user.admin? || user.accountant?
  end
end

