class PaymentPresenter < BasePresenter
  def date
    I18n.l @model.date
  end

  def interest_days
    "#{@model.interest.interest_days} / #{@model.interest.days_in_year}"
  end

  def amount
    h.number_to_currency(@model.sign * @model.amount)
  end

  def interest
    h.number_to_currency(@model.interest.amount)
  end
end
