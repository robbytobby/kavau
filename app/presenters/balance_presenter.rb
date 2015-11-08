class BalancePresenter < PaymentPresenter
  def date
    h.l @model.date
  end

  def end_amount
    h.number_to_currency @model.end_amount
  end
end
