class DisbursePresenter < PaymentPresenter
  def amount
    h.number_to_currency(-@model.amount)
  end

  def interest
    h.number_to_currency -@model.this_years_interest.amount
  end
end
