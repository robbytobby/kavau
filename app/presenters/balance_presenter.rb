class BalancePresenter < PaymentPresenter
  def start_amount
    h.number_to_currency(@model.start_amount)
  end

  def date
    h.l @model.date
  end

  def end_amount
    h.number_to_currency @model.end_amount
  end
end
