class ManualBalancePolicy < BalancePolicy
  def destroy?
    # TODO forbid destroy if balance has been sent to creditor
    user.admin? || user.accountant?
  end
end

