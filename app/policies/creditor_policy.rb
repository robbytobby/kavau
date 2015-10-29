class CreditorPolicy < AddressPolicy
  class Scope < Scope
    def resolve
      (user.admin? || user.accountant?) ? Address.creditors : Address.none
    end
  end

  def destroy?
    return false unless user.admin? || user.accountant?
    return false if record.credit_agreements.any?
    true
  end
end
