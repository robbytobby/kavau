class PdfPresenter < BasePresenter
  def created_at
    I18n.l(@model.created_at.to_date)
  end

  def confirmation_label
    [I18n.t('helpers.the_letter'), title].join(' ')
  end

  def item
    if letter.is_a?(TerminationLetter)
      "#{CreditAgreement.model_name.human} #{credit_agreement.number}"
    elsif letter.is_a?(DisburseLetter) || letter.is_a?(DepositLetter)
      "#{CreditAgreement.model_name.human} #{payment.credit_agreement.number} | #{payment.model_name.human} #{I18n.t('helpers.of_date')} #{I18n.l(payment.date)}"
    end
  end
end

