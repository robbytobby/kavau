class ProjectAddressPresenter < AddressPresenter
  def full_name(syntactic_sugar = nil)
    [name, legal_form].join(' ')
  end

  def legal_form
    I18n.t(@model.legal_form, scope: 'legal_forms')
  end

  def detail_line
    super + '</br>'.html_safe + legal_informations
  end

  def legal_informations
    return unless legal_information
    ['based_in', 'register_court', 'registration_number', 'ust_id', 'tax_number'].
      map{ |key| human_legal_information(key) }.compact.join(' | ')
  end

  def human_legal_information(key)
    return if legal_information[key].blank?
    "#{ProjectAddress.human_attribute_name(key)}: #{legal_information[key]}"
  end
end
