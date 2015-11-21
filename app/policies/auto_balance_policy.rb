class AutoBalancePolicy < BalancePolicy
  def index?
    false
  end

  def destroy?
    false
  end
end
