class TerminationLetter < Letter
  def title
    self[:subject] || I18n.t('pdf.title.termination_letter', text: '' )
  end

  def to_pdf(credit_agreement)
    TerminationPdf.new(credit_agreement, self).rendered
  end
end
