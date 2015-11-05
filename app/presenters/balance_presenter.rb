class BalancePresenter < PaymentPresenter
  def start_amount
    h.number_to_currency(@model.start_amount)
  end

  def interest
    h.number_to_currency @model.this_years_interest.amount
  end

  def interest_days
    #FIXME
    "#{@model.to_interest.interest_days} / #{@model.to_interest.days_in_year}"
  end
end
