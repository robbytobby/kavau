class BalancePresenter < PaymentPresenter
  def date
    h.l @model.date
  end

  def credit_agreement_link
    h.link_to_if h.policy(@model.credit_agreement).show?, @model.credit_agreement_id, @model.credit_agreement
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

  def deposits
    h.number_to_currency @model.deposits.sum(:amount)
  end

  def disburses
    h.number_to_currency @model.disburses.sum(:amount)
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
