class OrganizationPresenter < AddressPresenter
  def full_name(syntactic_sugar = nil)
    (name.split + [legal_form]).uniq.join(' ')
  end

  def legal_form
    I18n.t(@model.legal_form, scope: 'legal_forms')
  end
end
