class BalancePresenter < PaymentPresenter
  def start_amount
    h.number_to_currency(@model.start_amount)
  end

  def interest_days
    "#{@model.to_interest.interest_days} / #{@model.to_interest.days_in_year}"
  end

  def interest_from_start_amount
    h.number_to_currency @model.interest_from_start_amount.amount
  end

  def date
    h.l @model.date
  end

  def end_amount
    h.number_to_currency @model.end_amount
  end
end
