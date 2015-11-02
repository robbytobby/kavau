class PaymentPresenter < BasePresenter
  def date
    I18n.l @model.date
  end
end
