class TerminationLetter < Letter
  def title
    self[:subject] || I18n.t('pdf.title.termination_letter', text: '' )
  end
end
