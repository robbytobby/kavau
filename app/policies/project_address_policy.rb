class ProjectAddressPolicy < AddressPolicy
  def destroy?
    return false unless user.admin? || user.accountant?
    return false if record.credit_agreements.any?
    true
  end

  def permitted_params
    super + [:legal_form, :based_in, :register_court, :registration_number, :ust_id, :tax_number]
  end
end
