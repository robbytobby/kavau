class PaymentPresenter < BasePresenter
  def date
    I18n.l @model.date
  end

  def interest_days
    "#{@model.this_years_interest.interest_days} / #{@model.this_years_interest.days_in_year}"
  end
end
