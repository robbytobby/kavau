class TerminationBalancePolicy < BalancePolicy
  def index?
    false
  end

  def edit?
    false
  end

  def update?
    false
  end

  def destroy?
    user.admin? || user.accountant?
  end
end
