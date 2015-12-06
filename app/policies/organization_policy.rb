class OrganizationPolicy < CreditorPolicy
  def permitted_params
    super + [:legal_form]
  end
end
