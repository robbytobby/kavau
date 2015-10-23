class ProjectAddressPolicy < AddressPolicy
  def destroy?
    return false unless user.admin? || user.accountant?
    return false if record.credit_agreements.any?
    true
  end
end

