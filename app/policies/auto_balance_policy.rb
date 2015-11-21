class AutoBalancePolicy < BalancePolicy
  def index?
    false
  end

  def destroy?
    return false
  end
end
