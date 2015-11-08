class PaymentPresenter < BasePresenter
  def date
    I18n.l @model.date
  end

  def amount
    h.number_to_currency(@model.sign * @model.amount)
  end
end
