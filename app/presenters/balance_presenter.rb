class BalancePresenter < PaymentPresenter
  def date
    I18n.l @model.date
  end

  def credit_agreement_link
     
    h.link_to_if h.policy(@model.credit_agreement).show?, presented_credit_agreement.number, @model.credit_agreement
  end

  def presented_credit_agreement
    CreditAgreementPresenter.new(@model.credit_agreement, @view)
  end

  def creditor_link
    h.present(@model.creditor) do |c| 
      h.link_to_if h.policy(@model.creditor).show?, c.full_name, @model.creditor
    end
  end

  def start_amount
    h.number_to_currency @model.start_amount
  end

  def end_amount
    h.number_to_currency @model.end_amount
  end
  alias_method :amount, :end_amount

  def deposits
    h.number_to_currency @model.payments.where(sign: 1).sum(:amount)
  end

  def disburses
    h.number_to_currency @model.payments.where(sign: -1).sum(:amount)
  end

  def interests
    h.number_to_currency @model.interests_sum
  end

  def confirmation_label
    [
      I18n.t('confirmation_label.balance'),
      I18n.l(@model.date)
    ].join(' ')
  end
end
